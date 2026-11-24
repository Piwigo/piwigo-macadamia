{combine_script id='core.switchbox' load='async' require='jquery' path='themes/default/js/switchbox.js'}
{combine_script id='macadam.index' load='footer' path='themes/macadamia/js/index.js'}
{combine_script id='macadam.switchboxes' load='footer' path='themes/macadamia/js/switchboxes.js'}
{combine_css path="themes/default/vendor/fontello/css/gallery-icon.css" order=-10}

{if isset($errors) or isset($infos)}
  <div class="content messages">
    {include file='infos_errors.tpl'}
  </div>
{/if}
{if !empty($PLUGIN_INDEX_CONTENT_BEFORE)}{$PLUGIN_INDEX_CONTENT_BEFORE}{/if}

<div id="content" class="content">
  <div class="macadam-index-bar">
    <div class="macadam-breadcrumb-zone">
      <a href="{$U_HOME}"><i class="icon-home{if $TITLE|strstr:' / '} usable-icon{/if}"></i></a>
      <div id="breadcrumb">
        {if isset($page.section) and $page.section == 'table_of_content'}
          <h2> / {'Table of content'|translate}</h2>
        {elseif $TITLE|strstr:' / '}
          <h2>
            {$TITLE|regex_replace:"#^.*?(?= / )#":""}
          </h2>
        {/if}
        {$SELECTED_TAGS_TEMPLATE}
      </div>
    </div>

    <div class="macadam-actions-zone">
      <ul>
        {if isset($MACADAM_POSTED_CALENDAR_URL)}
          <li><a href="{$MACADAM_POSTED_CALENDAR_URL}"><i class="icon-calendar"></i></a>
          </li>
        {/if}

        {if !empty($category_thumbnails)}
          <li>
            <a id="toggleLayoutLink" style="cursor: pointer;"><i
                class="icon-grid"></i></a>
          </li>
        {/if}

        {if !empty($U_EDIT) or !empty($image_derivatives) or !empty($image_orders) or isset($U_SLIDESHOW)}
          <li class="dropdown-container">
            <a href="#" class="js-album-dropdown-trigger"
              style="cursor: pointer; color: inherit;">
              <i class="icon-wheel"></i>
            </a>
            <div class="album-dropdown-menu">
              <i class="icon-arrow-left index"></i>
              {if !empty($image_derivatives)}
                <div class="dropdown-item-sizes macadam-derivative-switch">
                  {strip}
                    <a id="derivativeSwitchLink" class="dropdown-item option-with-submenu"
                      rel="nofollow">

                      <i class="icon-photo-size"></i>
                      <span>{'Photo sizes'|@translate}</span>
                    </a>
                    <div id="derivativeSwitchBox" class="switchBox">
                      {foreach from=$image_derivatives item=image_derivative name=loop}
                        {if $image_derivative.SELECTED}
                          <span><i class=" icon-circled-true"></i>{$image_derivative.DISPLAY}</span>
                        {else}
                          <a href="{$image_derivative.URL}" rel="nofollow">{$image_derivative.DISPLAY}</a>
                        {/if}
                      {/foreach}
                    </div>

                  {/strip}
                </div>
              {/if}

              {if !empty($image_orders)}
                <div class="dropdown-item-sort">
                  <a id="sortOrderLink" class="dropdown-item gallery-icon-th-large" rel="nofollow" style="padding: 8px 10px;">
                    <i class="icon-arrow-left sort-order-arrow"></i>
                    <i class="icon-lines"></i> <span>{'Sort order'|@translate}</span>
                  </a>
                  <div id="sortOrderBox" class="switchBox">
                    <div class="switchBoxTitle">{'Sort order'|@translate}</div>
                    {foreach from=$image_orders item=image_order name=loop}
                      {if !$smarty.foreach.loop.first}<br>{/if}
                      {if $image_order.SELECTED}
                        <span class="sort-order-option selected">
                          <span class="sort-order-icon"><i class="icon-circled-true"></i></span>{$image_order.DISPLAY}
                        </span>
                      {else}
                        <a href="{$image_order.URL}" rel="nofollow">
                          <span class="sort-order-option">
                            <span class="sort-order-icon" aria-hidden="true"><i class="icon-circled-true"></i></span>{$image_order.DISPLAY}
                          </span>
                        </a>
                      {/if}
                    {/foreach}
                  </div>

                </div>
              {/if}

              {if isset($U_SLIDESHOW)}
                <a href="{$U_SLIDESHOW}" class="dropdown-item btn-slideshow"
                  rel="nofollow">
                  <i class="icon-play"></i>
                  <span>{'slideshow'|@translate}</span>
                </a>
              {/if}

              {if !empty($U_EDIT)}
                <a href="{$U_EDIT}" class="dropdown-item btn-edit-album">
                  <i class="icon-edit"></i>
                  <span>{'Edit album'|@translate}</span>
                </a>
              {/if}

            </div>
          </li>
        {/if}

        {if !empty($PLUGIN_INDEX_BUTTONS)}
          {foreach from=$PLUGIN_INDEX_BUTTONS item=button}
            <li class="plugin-index-button">{$button}</li>
          {/foreach}
        {/if}
      </ul>
    </div>
  </div>

  <div class="action-buttons">
    {if isset($COMBINABLE_TAGS)}
      {include file='include/related_tags.inc.tpl'}
    {/if}
  </div>
  <div class="mcs-container column">
    {if !empty($SEARCH_ID)}
      {include file='include/search_filters.inc.tpl'}
    {/if}
  </div>
  {* {if !isset($SEARCH_ID) and !isset($tag) and !isset($page.section)}
    <div class="table-of-content-container">
      <a href="{$ROOT_URL}index.php?/table_of_content" class="btn-table-of-content">
        <i class="icon-structure"></i>
        {'Table of content'|translate}
      </a>
    </div>
  {/if} *}
  {if !empty($PLUGIN_INDEX_CONTENT_BEGIN)}{$PLUGIN_INDEX_CONTENT_BEGIN}{/if}

  {if isset($page.section) and $page.section == 'table_of_content'}

    {if !empty($CONTENT)}{$CONTENT}{/if}
  {else}
    {if !empty($no_search_results)}
      <p class="search_results">{'No results for'|@translate} :
        <em><strong>
            {foreach $no_search_results as $res}
              {if !$res@first} &mdash; {/if}{$res}
            {/foreach}
          </strong></em>
      </p>
    {/if}

    {if !empty($category_search_results)}
      <p class="search_results">{'Album results for'|@translate} <strong>{$QUERY_SEARCH}</strong> :
        <em><strong>
            {foreach from=$category_search_results item=res name=res_loop}
              {if !$smarty.foreach.res_loop.first} &mdash; {/if}{$res}
            {/foreach}
          </strong></em>
      </p>
    {/if}

    {if !empty($tag_search_results)}
      <p class="search_results">{'Tag results for'|@translate} <strong>{$QUERY_SEARCH}</strong> :
        <em><strong>
            {foreach from=$tag_search_results item=tag name=res_loop}
              {if !$smarty.foreach.res_loop.first} &mdash; {/if} <a href="{$tag.URL}">{$tag.name}</a>
            {/foreach}
          </strong></em>
      </p>
    {/if}

    {if isset($FILE_CHRONOLOGY_VIEW)}
      {include file=$FILE_CHRONOLOGY_VIEW}
    {/if}

    {if !empty($CONTENT_DESCRIPTION)}
      <div class="additional_info">
        {$CONTENT_DESCRIPTION}
      </div>
    {/if}

    {if !empty($CONTENT)}{$CONTENT}{/if}
    {if !empty($CATEGORIES)}{$CATEGORIES}{/if}

    {if !empty($cats_navbar)}
      {include file='navigation_bar.tpl'|@get_extent:'navbar' navbar=$cats_navbar}
    {/if}

    {if !empty($THUMBNAILS)}
      <div class="loader"><img src="{$ROOT_URL}{$themeconf.img_dir}/ajax_loader.gif"></div>
      <ul class="thumbnails" id="thumbnails">
        {$THUMBNAILS}
      </ul>
    {else if !empty($SEARCH_ID)}
      <div class="mcs-no-result">
        <div class="text">
          <span class="top">{'No results are available.'|@translate}</span>
          <span class="bot">{'You can try to edit your filters and perform a new search.'|translate}</span>
        </div>
      </div>
    {/if}

    {if !empty($thumb_navbar)}
      {include file='navigation_bar.tpl'|@get_extent:'navbar' navbar=$thumb_navbar}
    {/if}
    {if !empty($PLUGIN_INDEX_CONTENT_END)}{$PLUGIN_INDEX_CONTENT_END}{/if}
  {/if}
</div>

{if !empty($PLUGIN_INDEX_CONTENT_AFTER)}{$PLUGIN_INDEX_CONTENT_AFTER}{/if}
