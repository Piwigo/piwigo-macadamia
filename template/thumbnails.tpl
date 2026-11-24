{if !empty($thumbnails)}
  {strip}
    {html_style}
    /* On conserve la compatibilité des tailles calculées si nécessaire */
    .thumbnails SPAN,
    .thumbnails .wrap2 A,
    .thumbnails LABEL {ldelim}
    width: {$derivative_params->max_width()+2}px;
    }
    .thumbnails .wrap2 {ldelim}
    height: {$derivative_params->max_height()+3}px;
    }
    {/html_style}

    {combine_script id='macadam.switchboxes' load='footer' path='themes/macadamia/js/switchboxes.js'}
    {combine_script id='macadam.thumbnail-config' load='footer' path='themes/macadamia/js/thumbnail-config.js'}

    {if !empty($category_thumbnails)}
      <p class="macadam-photos-grid-title">{'Photos'|@translate}</p>
    {/if}
    <div class="macadam-photos-grid macadam-size-{$derivative_params->type}">
      {foreach from=$thumbnails item=thumbnail}
        {assign var=derivative value=$pwg->derivative($derivative_params, $thumbnail.src_image)}
        {if !$derivative->is_cached()}
          {combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
          {combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
        {/if}

        <div class="macadam-photo-card">

          <a href="{$thumbnail.URL}" class="macadam-photo-link">
            <img class="photo-thumb-img" {if $derivative->is_cached()}src="{$derivative->get_url()}" {else}src="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" data-src="{$derivative->get_url()}" {/if}
              alt="{$thumbnail.TN_ALT}">
          </a>

          <div class="macadam-photo-infos">
            <div class="macadam-photo-text">
              <h4 class="photo-title" style="margin: 0; text-align: left;">
                {if !empty($thumbnail.NAME)}{$thumbnail.NAME}{else}Sans titre{/if}
              </h4>

              {if !empty($thumbnail.MACADAM_METADATA)}
                <span class="photo-meta">
                  {$thumbnail.MACADAM_METADATA|join:' - '}
                </span>
              {/if}
            </div>

            <div class="photo-actions-trigger">
              <i class="icon-three-dot"></i>
              <div class="pic-dropdown-menu">
                <a href="#" class="dropdown-item btn-share-pic">
                  <i class="icon-share"></i>
                  <span style="width: unset;">{'Share picture'|@translate}</span>
                </a>
                {if isset($U_EDIT) && isset($thumbnail.id)}
                  <a href="{$ROOT_URL}admin.php?page=photo-{$thumbnail.id}" class="dropdown-item btn-edit-pic">
                    <i class="icon-edit"></i>
                    <span style="width: unset;">{'Edit picture'|@translate}</span>
                  </a>
                {/if}
                {if isset($thumbnail.U_DOWNLOAD)}
                  <a href="{$thumbnail.U_DOWNLOAD}" class="dropdown-item btn-download-photos" rel="nofollow">
                    <i class="icon-add-drive"></i>
                    <span style="width: unset;">{'Download the picture'|@translate}</span>
                  </a>
                {/if}
              </div>
            </div>
          </div>
        </div>
      {/foreach}
    </div>
  {/strip}
  {/if}

  {combine_script id='macadam.thumbnails' load='footer' require='jquery' path='themes/macadamia/js/thumbnails.js'}