{if isset($MENUBAR)}{$MENUBAR}{/if}
<div id="content" class="content{if isset($MENUBAR)} contentWithMenu{/if} contentTags">

  <div class="macadam-index-bar">
    <div class="macadam-breadcrumb-zone">
      <div id="breadcrumb">
        <h2>
          <a href="{$U_HOME}" class="sidebar-icon-link"><i class="icon-home"></i></a>
          {$SECTION_TITLE}<span class="browsePathSeparator"> {$LEVEL_SEPARATOR} </span>{'Tags'|@translate}
        </h2>

        <div class="macadam-tags-headline">
          {if isset($tags)}
            <span class="tags-badge-count">{$tags|@count}</span>
          {/if}
        </div>

      </div>
    </div>

    <div class="macadam-actions-zone">
      <ul>
        {if isset($U_MODE_POSTED)}
          <li><a href="{$U_MODE_POSTED}&amp;view=month"><i class="icon-calendar"></i></a>
          </li>
        {elseif isset($U_MODE_CREATED)}
          <li><a href="{$U_MODE_CREATED}&amp;view=month"><i class="icon-calendar"></i></a>
          </li>
        {/if}

        <li>
          <a id="toggleLayoutLink" style="cursor: pointer;"><i
              class="icon-grid"></i></a>
        </li>

        {if isset($U_EDIT)}
          <li class="dropdown-container">
            <a href="#" class="js-album-dropdown-trigger"
              style="cursor: pointer; color: inherit;">
              <i class="icon-wheel"></i>
            </a>
            <div class="album-dropdown-menu">
              <i class="icon-arrow-left index"></i>
              {if !empty($image_derivatives)}
                <div class="dropdown-item-sizes">
                  {strip}
                    <a id="derivativeSwitchLink" class="dropdown-item option-with-submenu"
                      rel="nofollow">
                      <i class="icon-photo-size"></i>
                      <span>{'Photo sizes'|@translate}</span>
                    </a>
                    <div id="derivativeSwitchBox" class="switchBox">
                      <div class="switchBoxTitle">{'Photo sizes'|@translate}</div>
                      {foreach from=$image_derivatives item=image_derivative name=loop}
                        {if !$smarty.foreach.loop.first}<br>{/if}
                        {if $image_derivative.SELECTED}
                          <span>&#x2714; </span>{$image_derivative.DISPLAY}
                        {else}
                          <a href="{$image_derivative.URL}" rel="nofollow">{$image_derivative.DISPLAY}</a>
                        {/if}
                      {/foreach}
                    </div>
                    {footer_script}(window.SwitchBox=window.SwitchBox||[]).push("#derivativeSwitchLink",
                    "#derivativeSwitchBox");{/footer_script}
                  {/strip}
                </div>
              {/if}

              {if !empty($image_orders)}
                <div class="dropdown-item-sort">
                  <a id="sortOrderLink" class="dropdown-item gallery-icon-th-large"
                    rel="nofollow">
                    <i class="icon-sort"></i> <span>{'Sort order'|@translate}</span>
                  </a>
                  <div id="sortOrderBox" class="switchBox">
                    <div class="switchBoxTitle">{'Sort order'|@translate}</div>
                    {foreach from=$image_orders item=image_order name=loop}
                      {if !$smarty.foreach.loop.first}<br>{/if}
                      {if $image_order.SELECTED}
                        <span>&#x2714; </span>{$image_order.DISPLAY}
                      {else}
                        <span style="visibility:hidden">&#x2714; </span><a href="{$image_order.URL}"
                          rel="nofollow">{$image_order.DISPLAY}</a>
                      {/if}
                    {/foreach}
                  </div>
                  {footer_script}(window.SwitchBox=window.SwitchBox||[]).push("#sortOrderLink",
                  "#sortOrderBox");{/footer_script}
                </div>
              {/if}

              {if isset($U_SLIDESHOW)}
                <a href="{$U_SLIDESHOW}" class="dropdown-item btn-slideshow"
                  rel="nofollow">
                  <i class="icon-play"></i>
                  <span>{'slideshow'|@translate}</span>
                </a>
              {/if}

              <a href="{$U_EDIT}" class="dropdown-item btn-edit-album">
                <i class="icon-edit"></i>
                <span>{'Edit album'|@translate}</span>
              </a>
            </div>
          </li>
        {elseif isset($U_ADMIN)}
          <li><a href="{$U_ADMIN}" class="gallery-icon-cog"><i
                class="icon-wheel"></i></a></li>
        {/if}
      </ul>
    </div>
  </div>


  {include file='infos_errors.tpl'}


  {if $display_mode == 'cloud' and isset($tags)}
    <div id="fullTagCloud">
      {foreach from=$tags item=tag}
        <span><a href="{$tag.URL}" class="tagLevel{$tag.level}">{$tag.name}</a></span>
      {/foreach}
    </div>
  {/if}

  {if $display_mode == 'letters' and isset($letters)}
    <table>
      <tr>
        <td valign="top">
          {foreach from=$letters item=letter}
            <fieldset class="tagLetter">
              <legend class="tagLetterLegend">{$letter.TITLE}</legend>
              <table class="tagLetterContent">
                {foreach from=$letter.tags item=tag}
                  <tr class="tagLine">
                    <td><a href="{$tag.URL}">{$tag.name}</a></td>
                    <td class="nbEntries">{$tag.counter|@translate_dec:'%d photo':'%d photos'}</td>
                  </tr>
                {/foreach}
              </table>
            </fieldset>
            {if isset($letter.CHANGE_COLUMN) }
            </td>
            <td valign="top">
            {/if}
          {/foreach}
        </td>
      </tr>
    </table>
  {/if}

</div> <!-- content -->