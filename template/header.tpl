<!DOCTYPE html>
<html lang="{$lang_info.code}" dir="{$lang_info.direction}">

<head>
  {if $SHOW_MOBILE_APP_BANNER}
    <meta name="apple-itunes-app" content="app-id=472225196">
  {/if}
  <meta charset="{$CONTENT_ENCODING}">
  <meta name="generator" content="Piwigo (aka PWG), see piwigo.org">

  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  {if isset($meta_ref)}
    {if isset($INFO_AUTHOR)}
      <meta name="author" content="{$INFO_AUTHOR|strip_tags:false|replace:'"':' '}">
  {/if}
  {if isset($related_tags)}
  <meta name="keywords"
    content="{foreach from=$related_tags item=tag name=tag_loop}{if !$smarty.foreach.tag_loop.first}, {/if}{$tag.name}{/foreach}">
  {/if}
  {if isset($COMMENT_IMG)}
  <meta name="description"
    content="{$COMMENT_IMG|strip_tags:false|replace:'"':' '}{if isset($INFO_FILE)} - {$INFO_FILE}{/if}">
    {else}
      <meta name="description" content="{$PAGE_TITLE}{if isset($INFO_FILE)} - {$INFO_FILE}{/if}">
    {/if}
  {/if}

  <title>
    {if $PAGE_TITLE!=l10n('Home') && $PAGE_TITLE!=$GALLERY_TITLE}{$PAGE_TITLE} | {/if}{$GALLERY_TITLE}
  </title>
  <link rel="shortcut icon" type="image/x-icon" href="{$ROOT_URL}{$themeconf.icon_dir}/favicon.ico">

  <link rel="start" href="{$U_HOME}">
  <link rel="search" href="{$ROOT_URL}search.php">

  {if isset($U_PREFETCH)    }
    <link rel="prefetch" href="{$U_PREFETCH}">
  {/if}
  {if isset($U_CANONICAL)   }
    <link rel="canonical" href="{$U_CANONICAL}">
  {/if}

  {if not empty($page_refresh)}
    <meta http-equiv="refresh" content="{$page_refresh.TIME};url={$page_refresh.U_REFRESH}">
  {/if}

  {strip}
    {foreach from=$themes item=theme}
      {if $theme.load_css}
        {* For the parent theme (e.g. 'default'), load its standard 'theme.css' file. *}
        {if $theme.id != 'macadam'}
          {combine_css path="themes/`$theme.id`/theme.css" order=-10}
          {* For our specific 'macadam' theme, load its CSS from the correct subfolder. *}
        {else}
          {* Import Fontello CSS *}
          {combine_css path="themes/macadam/css/fontello/css/fontello.css" order=-11}
          {combine_css path="themes/macadam/css/macadam.css" order=-10}
          {combine_css path="themes/macadam/css/album.css" order=-10}
          {combine_css path="themes/macadam/css/thumbnail.css" order=-10}
          {combine_css path="themes/macadam/css/picture.css" order=-10}
          {combine_css path="themes/macadam/css/calendar.css" order=-10}
        {/if}
      {/if}
      {if !empty($theme.local_head)}
        {include file=$theme.local_head load_css=$theme.load_css}
      {/if}
    {/foreach}

    {combine_css path="themes/macadam/css/header.css" order=-9}

    {combine_script id="jquery" load="footer"}
  {/strip}

  {get_combined_css}

  {get_combined_scripts load='header'}
  {if not empty($head_elements)}
    {foreach from=$head_elements item=elt}
      {$elt}
    {/foreach}
  {/if}
</head>

<body id="{$BODY_ID}" class="{foreach from=$BODY_CLASSES item=class}{$class} {/foreach}" data-infos='{$BODY_DATA}'>

  <nav class="macadam-sidebar-nav">
    <div class="mobile-menu-overlay"></div>
    <div class="sidebar-menu-links">
      <a href="{$U_HOME}" class="sidebar-icon-link"><i class="icon-home"></i></a>
      <a href="{$ROOT_URL}search.php" class="sidebar-icon-link"><i
          class="icon-lens"></i></a>

      {* Dropdown container for Albums *}
      <div class="sidebar-dropdown-container sidebar-dropdown-container-album">
        <a onclick="return false;" class="sidebar-icon-link sidebar-icon-link-drop"><i class="icon-structure"></i></a>

        <div class="sidebar-dropdown-menu album-menu">
          <i class="icon-cross usable-icon mobile-close-btn"></i>
          <div class="dropdown-menu-title menu-title-album-w-toc">{'Albums'|translate}
            <a href="{$ROOT_URL}index.php?/table_of_content" class="btn-table-of-content">
              <i class="icon-enter-fullscreen"></i>
            </a>
          </div>
          <ul class="album-dropdown-list">
            {if isset($MACADAM_HEADER_ALBUMS) && !empty($MACADAM_HEADER_ALBUMS)}

              {* Define a recursive function to handle infinite album depth *}
              {function name=render_album_list depth=0}
                {foreach from=$albums item=album}
                  <li{if !empty($album.sub_albums)} class="has-sub-albums" {/if}>
                    <div class="album-item-row" style="padding-left: {$depth * 30 + 20}px;">
                      {if !empty($album.sub_albums)}
                        <span class="album-toggle"><i class="icon-arrow-right"></i></span>
                      {else}
                        <span class="album-toggle-disabled"><i class="icon-arrow-right"></i></span>
                      {/if}
                      <a href="{$album.URL}">{$album.name}</a>
                      <div class="album-counts">
                        {if $album.count_images > 0}
                          <span class="album-count">{$album.count_images}<i
                              class="icon-picture"></i></span>
                        {/if}
                        {if $album.count_categories > 0}
                          <span class="album-count">{$album.count_categories}<i
                              class="icon-folder"></i></span>
                        {/if}
                      </div>
                    </div>
                    {if !empty($album.sub_albums)}
                      <ul class="sub-album-list">
                        {call name=render_album_list albums=$album.sub_albums depth=$depth+1}
                      </ul>
                    {/if}
                    </li>
                  {/foreach}
                {/function}

                {* Call the function with the root albums *}
                {call name=render_album_list albums=$MACADAM_HEADER_ALBUMS depth=0}
              {else}
                <li>
                  <div class="album-item-row"><a>{'No albums'|translate}</a></div>
                </li>
              {/if}
          </ul>

          {if isset($MACADAM_TOTAL_ALBUMS) && $MACADAM_TOTAL_ALBUMS > 0}
            <div class="dropdown-menu-footer">
              <div class="album-item-row" style="gap: 35px;">
                <span class="">{$MACADAM_TOTAL_ALBUMS} <i
                    class="icon-folder"></i></span>
                <span class="">{$MACADAM_TOTAL_IMAGES} <i
                    class="icon-picture"></i></span>
              </div>
            </div>
          {/if}
        </div>
      </div>

      {* <a href="{$U_MODE_CREATED|default:" `$ROOT_URL`index.php?/created-monthly"}" class="sidebar-icon-link"><i class="icon-add"></i></a> *}

      {* Dropdown container for Explore *}
      <div class="sidebar-dropdown-container">
        <a class="sidebar-icon-link sidebar-icon-link-drop">
          <i class="icon-add"></i>
        </a>
        <div class="sidebar-dropdown-menu">
          <i class="icon-cross usable-icon mobile-close-btn"></i>
          <div class="dropdown-menu-title">{'Explore'|translate}</div>
          <ul class="album-dropdown-list">
            {if isset($blocks.mbSpecials)}
              {foreach from=$blocks.mbSpecials->data item=link}
                <li>
                  <div class="tag-item-row">
                    <a href="{$link.URL}" {if isset($link.REL)} {$link.REL}{/if}>
                      {$link.NAME}
                    </a>
                  </div>
                </li>
              {/foreach}
            {/if}
            <li>
              <div class="tag-item-row">
                <a href="{$ROOT_URL}index.php?/table_of_content">
                  {'Table of content'|translate}</a>
              </div>
            </li>
            <li>
              <div class="tag-item-row"><a href="{$collection.url}">{'Collections'|translate}</a></div>
            </li>
            {* <hr> *}
            {if isset($blocks.mbMenu->data.tags)}
              {assign var='tag_link' value=$blocks.mbMenu->data.tags}
              <li>
                <div class="tag-item-row">
                  <a href="{$tag_link.URL}">
                    {$tag_link.NAME}
                    {if isset($tag_link.COUNTER) and $tag_link.COUNTER > 0}
                      <span class="menu-counter">{$tag_link.COUNTER}</span>
                    {/if}
                  </a>
                </div>
              </li>
            {/if}
            {if isset($blocks.mbMenu->data.comments)}
              {assign var='comment_link' value=$blocks.mbMenu->data.comments}
              <li>
                <div class="tag-item-row">
                  <a href="{$comment_link.URL}">
                    {$comment_link.NAME}
                    {if isset($comment_link.COUNTER) and $comment_link.COUNTER > 0}
                      <span class="menu-counter">{$comment_link.COUNTER}</span>
                    {/if}
                  </a>
                </div>
              </li>
            {/if}
            {if isset($MACADAM_HEADER_CONTACT)}
              <li>
                <div class="tag-item-row">
                  <a href="{$MACADAM_HEADER_CONTACT.URL}">
                    {$MACADAM_HEADER_CONTACT.NAME}
                  </a>
                </div>
              </li>
            {/if}
          </ul>
        </div>
      </div>

      {* Dropdown container for Tags *}
      <div class="sidebar-dropdown-container sidebar-dropdown-container-tags">
        <a class="sidebar-icon-link sidebar-icon-link-drop"><i
            class="icon-tags"></i></a>
        <div class="sidebar-dropdown-menu">
          <i class="icon-cross usable-icon mobile-close-btn"></i>
          <div class="dropdown-menu-title">{'Tags'|translate}</div>
          <ul class="album-dropdown-list">
            {if isset($MACADAM_HEADER_TAGS) && !empty($MACADAM_HEADER_TAGS)}
              {foreach from=$MACADAM_HEADER_TAGS item=tag}
                <li>
                  <div class="tag-item-row"><a href="{$tag.URL}">{$tag.name}</a></div>
                </li>
              {/foreach}
            {else}
              <li>
                <div class="tag-item-row"><a>{'No tags'|translate}</a></div>
              </li>
            {/if}
          </ul>
        </div>
      </div>

      {* Dropdown container for Collections / Favorites *}
      <div class="sidebar-dropdown-container sidebar-dropdown-container-collections">
        {if isset($user_collections)}
          <a class="sidebar-icon-link-drop sidebar-icon-link"><i
              class="icon-star"></i></a>
          <div class="sidebar-dropdown-menu">
            <i class="icon-cross usable-icon mobile-close-btn"></i>
            <div class="dropdown-menu-title">{'Collections'|translate}</div>
            <ul class="album-dropdown-list">
              {if !empty($user_collections)}
                {foreach from=$user_collections item=collection}
                  <li>
                    <div class="tag-item-row"><a href="{$collection.url}">{$collection.name}</a></div>
                  </li>
                {/foreach}
              {else}
                <li>
                  <div class="tag-item-row"><a>{'No collections'|translate}</a></div>
                </li>
              {/if}
            </ul>
          </div>
        {else}
          <a class="sidebar-icon-link-drop sidebar-icon-link"><i
              class="icon-star"></i></a>
          <div class="sidebar-dropdown-menu">
            <i class="icon-cross usable-icon mobile-close-btn"></i>
            <div class="dropdown-menu-title">{'Favorites'|translate}</div>
            <ul class="album-dropdown-list">
              {if isset($MACADAM_HEADER_FAVORITES) && !empty($MACADAM_HEADER_FAVORITES)}
                {foreach from=$MACADAM_HEADER_FAVORITES item=fav}
                  <li>
                    <div class="tag-item-row"><a href="{$fav.URL}">{$fav.name}</a></div>
                  </li>
                {/foreach}
              {else}
                <li>
                  <div class="tag-item-row"><a>{'No favorites'|translate}</a></div>
                </li>
              {/if}
            </ul>
          </div>
        {/if}
      </div>

      {if isset($U_LOGIN_REGISTER)}
        <a href="{$U_LOGIN_REGISTER}" class="sidebar-icon-link"><i
            class="icon-person"></i></a>
      {else}
        <div class="sidebar-dropdown-container">
          <a  onclick="return false;" class="sidebar-icon-link sidebar-icon-link-drop"><i class="icon-person"></i></a>
          <div class="sidebar-dropdown-menu">
            <i class="icon-cross usable-icon mobile-close-btn"></i>
            <div class="dropdown-menu-title">{'Account'|translate}</div>
            <ul class="album-dropdown-list">
              {if isset($U_ADMIN)}
                <li>
                  <div class="tag-item-row"><a href="{$U_ADMIN}">{'Administration'|translate}</a></div>
                </li>
              {/if}
              <li>
                <div class="tag-item-row">
                  <a
                    href="{$U_PHOTO_ADMIN|default:$U_PROFILE|default:" `$ROOT_URL`profile.php"}">{'Customize'|translate}</a>
                </div>
              </li>
              {if isset($blocks.mbMenu->data.rss)}
                {assign var='notif_link' value=$blocks.mbMenu->data.rss}
                <li>
                  <div class="tag-item-row">
                    <a href="{$notif_link.URL}" {if isset($notif_link.REL)}
                      {$notif_link.REL}{/if}>
                      {$notif_link.NAME}
                    </a>
                  </div>
                </li>
              {/if}
              <li>
                <div class="tag-item-row"><a href="{$ROOT_URL}admin.php?page=photos_add">{'Add photos'|translate}</a>
                </div>
              </li>
              <li>
                <div class="tag-item-row"><a href="{$ROOT_URL}admin.php?page=batch_manager">{'Edit photos'|translate}</a>
                </div>
              </li>
            </ul>
            {if isset($U_LOGOUT)}
              <div class="dropdown-menu-footer" style="justify-content: start; padding-top: 20px;">
                <div class="tag-item-row" style="padding-bottom: 10px;">
                  <a href="{$U_LOGOUT}">{'Logout'|translate}</a>
                </div>
              </div>
            {/if}
          </div>
        </div>
      {/if}
    </div>

    {* Script to handle sub-albums toggle on click *}
    <script>
      document.addEventListener('DOMContentLoaded', function() {
        var overlay = document.querySelector('.mobile-menu-overlay');

        function closeAllMenus() {
          document.querySelectorAll('.sidebar-dropdown-container.mobile-active').forEach(function(c) {
            c.classList.remove('mobile-active');
          });
          if (overlay) overlay.classList.remove('active');
          document.body.style.overflow = '';
        }

        if (overlay) {
          overlay.addEventListener('click', function() {
            closeAllMenus();
          });
        }

        /* Align dropdown menu top with the vertical position of the button */
        document.querySelectorAll('.sidebar-dropdown-container').forEach(function(container) {
          var menu = container.querySelector('.sidebar-dropdown-menu');
          if (menu) {
            container.addEventListener('mouseenter', function() {
              if (window.innerWidth > 768) {
                var rect = container.getBoundingClientRect();
                menu.style.top = rect.top - 21 + 'px';
              }
            });

            var toggleBtn = container.querySelector('.sidebar-icon-link-drop');
            if (toggleBtn) {
              toggleBtn.addEventListener('click', function(e) {
                if (window.innerWidth <= 768) {
                  e.preventDefault();

                  if (container.classList.contains('mobile-active')) {
                    container.classList.remove('mobile-active');
                    document.body.style.overflow = '';
                    return;
                  }

                  document.querySelectorAll('.sidebar-dropdown-container.mobile-active').forEach(function(
                    activeContainer) {
                    activeContainer.classList.remove('mobile-active');
                  });

                  container.classList.add('mobile-active');
                  document.body.style.overflow = 'hidden';
                }
              });
            }

            var closeBtn = container.querySelector('.mobile-close-btn');
            if (closeBtn) {
              closeBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                closeAllMenus();
              });
            }
          }
        });
      });
    </script>
    {footer_script}
    jQuery(document).ready(function($) {
    $('.sidebar-dropdown-menu').on('click', '.album-toggle', function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(this).toggleClass('open');
    $(this).closest('li').children('.sub-album-list').slideToggle(250);
    });
    });
    {/footer_script}
  </nav>

  <div id="the_page" class="macadam-main-container">

    <div id="theHeader" class="macadam-header-banner {if $BODY_ID == 'thePicturePage'}picture-header-only{/if}"
      style="height: {$MACADAM_HEADER_HEIGHT|escape:'html'};{if !empty($MACADAM_HEADER_IMAGE_URL)} background-image: url('{$MACADAM_HEADER_IMAGE_URL|escape:'html'}');{/if}">
      <div class="macadam-header-content">

        {if $BODY_ID != 'thePicturePage'}
          <h1 class="macadam-gallery-title">DEMO GALLERY</h1>
        {/if}

        <div class="macadam-header-search">
          <form action="{$ROOT_URL}search.php" method="get">
            <i class="search-icon icon-lens"></i>
            <input type="text" name="q" placeholder="Search" autocomplete="off">
          </form>

        </div>

      </div>
    </div>

    {if not empty($header_notes)}
      <div class="header_notes">
        {foreach from=$header_notes item=elt}
          <p>{$elt}</p>
        {/foreach}
      </div>
{/if}