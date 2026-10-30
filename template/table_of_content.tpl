<div class="toc-panel">
  <ul class="toc-album-list">
    {if isset($MACADAM_HEADER_ALBUMS) && !empty($MACADAM_HEADER_ALBUMS)}

      {function name=render_toc_list depth=0}
        {foreach from=$albums item=album}
          <li class="toc-album-item {if !empty($album.sub_albums)}has-sub-albums{/if}">
            <div class="album-item-row" style="padding-left: {$depth * 24 + 10}px;">
              
              {if !empty($album.sub_albums)}
                <span class="album-toggle"><i class="icon-arrow-right"></i></span>
              {else}
                <span class="album-toggle-disabled"><i class="icon-arrow-right"></i></span>
              {/if}
              
              <a class="album-link" href="{$album.URL}">{$album.name}</a>
              <div class="album-counts">
                {if $album.count_categories > 0}
                  <span class="album-count subfolders-badge">
                    {$album.count_categories} <i class="icon-folder"></i>
                  </span>
                {/if}
                {if $album.count_images > 0}
                  <span class="album-count images-badge">
                    {$album.count_images} <i class="icon-picture"></i>
                  </span>
                {/if}
              </div>
            </div>

            {if !empty($album.sub_albums)}
              <ul class="sub-album-list">
                {call name=render_toc_list albums=$album.sub_albums depth=$depth+1}
              </ul>
            {/if}
          </li>
        {/foreach}
      {/function}

      {call name=render_toc_list albums=$MACADAM_HEADER_ALBUMS depth=0}

    {else}
      <li class="toc-no-album">{'No albums'|translate}</li>
    {/if}
  </ul>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.toc-album-item.has-sub-albums .album-toggle').forEach(function(toggle) {
    toggle.addEventListener('click', function(e) {
      e.stopPropagation();
      var li = toggle.closest('.toc-album-item');
      li.classList.toggle('expanded');
    });
  });
});
</script>