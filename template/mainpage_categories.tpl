{strip}{html_style}
  .thumbnailCategory .illustration {ldelim}
  width: {$derivative_params->max_width()+5}px;
  }
  .content .thumbnailCategory .description {ldelim}
  height: {$derivative_params->max_height()+5}px;
  }
  {/html_style}{/strip}

  {combine_script id='macadam.albums' load='footer' require='jquery' path='themes/macadam/js/albums.js'}
  {combine_script id='macadam.thumbnail-config' load='footer' path='themes/macadam/js/thumbnail-config.js'}

  <div class="loader" data-error-icon="{$ROOT_URL}{$themeconf.icon_dir}/errors_small.png"><img src="{$ROOT_URL}{$themeconf.img_dir}/ajax_loader.gif"></div>

  {function name=render_album_cards albums=$category_thumbnails depth=0 pwg=$pwg derivative_params=$derivative_params}
    {foreach from=$albums item=cat name=cat_loop}
      <div class="album-wrapper{if $depth > 0} is-sub-album{/if}">

      {assign var=derivative value=null}
      {assign var=main_img_id value=$cat.representative_picture_id|default:0}
      {if isset($cat.representative) && !empty($cat.representative.src_image)}
        {assign var=derivative value=$pwg->derivative($derivative_params, $cat.representative.src_image)}
      {/if}

      {macadam_get_extra_images cat_id=$cat.id main_img_id=$main_img_id assign="extra_images"}
      {assign var=extra_derivative_1 value=null}
      {assign var=extra_derivative_2 value=null}
      {if isset($extra_images[0])}
        {assign var=extra_derivative_1 value=$pwg->derivative($derivative_params, $extra_images[0].src_image)}
      {/if}
      {if isset($extra_images[1])}
        {assign var=extra_derivative_2 value=$pwg->derivative($derivative_params, $extra_images[1].src_image)}
      {/if}

      {assign var=needs_loader value=false}
      {if (isset($derivative) && !$derivative->is_cached())
        || (isset($extra_derivative_1) && !$extra_derivative_1->is_cached())
        || (isset($extra_derivative_2) && !$extra_derivative_2->is_cached())
      }
        {assign var=needs_loader value=true}
      {/if}

      {if $needs_loader}
        {combine_script id='jquery.ajaxmanager' path='themes/default/js/plugins/jquery.ajaxmanager.js' load='footer'}
        {combine_script id='thumbnails.loader' path='themes/default/js/thumbnails.loader.js' require='jquery.ajaxmanager' load='footer'}
      {/if}

      <div class="macadam-album-card" data-id="{$cat.id}" data-parent="{$cat.id_UP|default:0}" {if $depth > 0}style="margin-left: {$depth * 55}px; width: calc(100% - {$depth * 55}px); background: var(--color-variable-5);" {/if}>

        <a href="{$cat.URL}" class="macadam-album-thumbs">
          <div class="main-thumb-container">
            {if isset($derivative)}
              <img {if $derivative->is_cached()}src="{$derivative->get_url()}" {else}src="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" data-src="{$derivative->get_url()}" {/if} alt="{$cat.TN_ALT}"':' '|@strip_tags:false} - {'display this album'|@translate}" class="main-thumb">
              {else}
              <div class="no-thumb-placeholder"></div>
            {/if}
          </div>

          <div class="sub-thumbs-container">
            {if isset($extra_derivative_1)}
              <img {if $extra_derivative_1->is_cached()}src="{$extra_derivative_1->get_url()}" {else}src="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" data-src="{$extra_derivative_1->get_url()}" {/if} class="thumb-sub-block" alt="">
              {else}
              <div class="thumb-sub-block sub-orange"></div>
            {/if}

            {if isset($extra_derivative_2)}
              <img {if $extra_derivative_2->is_cached()}src="{$extra_derivative_2->get_url()}" {else}src="{$ROOT_URL}{$themeconf.icon_dir}/img_small.png" data-src="{$extra_derivative_2->get_url()}" {/if} class="thumb-sub-block" alt="">
              {else}
              <div class="thumb-sub-block sub-beige"></div>
            {/if}
          </div>
        </a>

        <div class="macadam-album-infos">
          <div class="macadam-album-header">
            <div>
              <h3 class="album-title">
                <a href="{$cat.URL}">{$cat.NAME}</a>
              </h3>
              <span class="album-meta">
                {$cat.nb_images|default:0} {if $cat.nb_images|default:0 > 1}{'photos'|translate}{else}{'photo'|translate}{/if}
                {if isset($cat.count_categories) and $cat.count_categories > 0}
                  , {$cat.count_categories} {if $cat.count_categories > 1}{'albums'|translate}{else}{'album'|translate}{/if}
                {/if}
              </span>
            </div>

            <div class="album-actions-trigger">
              <i class="icon-three-dot"></i>

              <div class="album-dropdown-menu">
                {if $SHAREALBUM_ACTIVE}
                  <a href="#" class="dropdown-item btn-share-album" data-has-link="{if isset($SHAREALBUM_LINKS[$cat.id])}true{else}false{/if}" data-share-url="{if isset($SHAREALBUM_LINKS[$cat.id])}{$SHAREALBUM_LINKS[$cat.id]}{/if}">
                    <i class="icon-share"></i>
                    <span>{'Share album'|@translate}</span>
                  </a>
                {/if}
                <a href="{$ROOT_URL}admin.php?page=album-{$cat.id}" class="dropdown-item btn-edit-album">
                  <i class="icon-edit"></i>
                  <span>{'Edit album'|@translate}</span>
                </a>
                <a href="{$ROOT_URL}admin.php?page=photos_add&amp;album={$cat.id}" class="dropdown-item btn-add-photos">
                  <i class="icon-add"></i>
                  <span>{'Add photos to the album'|@translate}</span>
                </a>
              </div>
            </div>
          </div>

          <div class="album-description-zone">
            {if !empty($cat.DESCRIPTION)}
              <p class="album-description">{$cat.DESCRIPTION}</p>
              {else}
              <p class="album-description empty-desc"></p>
            {/if}
          </div>

          {if isset($cat.count_categories) and $cat.count_categories > 0}
            <div class="album-footer-icon">
              <a href="{$cat.URL}" class="album-sub-toggle">
                <i class="icon-arrow-down"></i>
              </a>
            </div>
          {/if}
        </div>
      </div>
      {if isset($cat.count_categories) and $cat.count_categories > 0}
        <div class="sub-albums-container">
          {if isset($MACADAM_ALL_ALBUMS[$cat.id].sub_albums) && !empty($MACADAM_ALL_ALBUMS[$cat.id].sub_albums)}
            {call name=render_album_cards albums=$MACADAM_ALL_ALBUMS[$cat.id].sub_albums depth=$depth+1 pwg=$pwg derivative_params=$derivative_params}
          {/if}
        </div>
      {/if}
    </div>
  {/foreach}
{/function}

{macadam_has_photos assign="has_photos"}
{if $has_photos}
  <p class="macadam-photos-grid-title-al">{'Albums'|@translate}</p>
{/if}
<div class="macadam-albums-container macadam-main-grid-active">
  {call name=render_album_cards albums=$category_thumbnails depth=0 pwg=$pwg derivative_params=$derivative_params}
</div>
