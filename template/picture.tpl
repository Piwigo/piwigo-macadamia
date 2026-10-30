{combine_script id='core.switchbox' load='async' require='jquery' path='themes/default/js/switchbox.js'}
{if isset($MENUBAR)}{$MENUBAR}{/if}

<div id="content">

  {if isset($errors) or not empty($infos)}
    {include file='infos_errors.tpl'}
  {/if}

  {if !empty($PLUGIN_PICTURE_BEFORE)}{$PLUGIN_PICTURE_BEFORE}{/if}

  <div class="macadam-picture-container">

    <div class="macadam-picture-viewer">

      <div class="macadam-index-bar picture-index-bar">
        <div class="macadam-breadcrumb-zone">
          <div id="breadcrumb">
            <h2>
              <a href="{$U_HOME}" class="sidebar-icon-link"><i class="icon-home"></i></a>
              <span class="intermediate-album">{$SECTION_TITLE}</span><span class="browsePathSeparator">
                {$LEVEL_SEPARATOR} </span><span class="breadcrumb-current-tittle">{$current.TITLE}</span>
            </h2>
          </div>
        </div>
        <div class="macadam-actions-zone">
          <div class="macadam-dropdown-actions">

            <span class="fullscreen-icon-container" id="macadam-fullscreen-toggle">
              <i class="icon-enter-fullscreen"></i>
            </span>

            <div class="dropdown-container">
              <a href="#" class="js-picture-dropdown-trigger"
                style="cursor: pointer; color: inherit;">
                <i class="icon-wheel"></i>
              </a>

              <div class="album-dropdown-menu">
                {assign var='real_derivatives_count' value=0}
                {foreach from=$current.unique_derivatives item=derivative key=derivative_type}
                  {if $derivative_type|lower != 'original' && $derivative->get_type()|lower != 'original'}
                    {assign var='real_derivatives_count' value=$real_derivatives_count+1}
                  {/if}
                {/foreach}
                {if $real_derivatives_count > 1}
                <i class="icon-arrow-left index"></i>
                {footer_script require='jquery'}
                {literal}
                  function changeImgSrc(url,typeSave,typeMap) {
                  var theImg = document.getElementById("theMainImage");
                  if (theImg) {
                  theImg.removeAttribute("width"); theImg.removeAttribute("height");
                  theImg.src = url;
                  theImg.classList.remove('macadam-natural-size');
                  theImg.classList.add('macadam-natural-size');
                  theImg.useMap = "#map"+typeMap;
                  }
                  jQuery('#derivativeSwitchBox .switchCheck').css('visibility','hidden');
                  jQuery('#derivativeChecked'+typeMap).css('visibility','visible');
                  document.cookie = 'picture_deriv='+typeSave+';path={/literal}{$COOKIE_PATH}{literal}';
                  document.cookie = 'macadam_auto_derivative=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path={/literal}{$COOKIE_PATH}{literal}';
                  }

                  jQuery(function() {
                    var $link = jQuery('#derivativeSwitchLink');
                    var $box = jQuery('#derivativeSwitchBox');

                    if (!$link.length || !$box.length) return;

                    $link.on('click', function(e) {
                      e.preventDefault();
                      e.stopPropagation();
                      var isVisible = $box.is(':visible');
                      $box.css({
                        display: isVisible ? 'none' : 'block',
                        left: 'auto',
                        right: 'calc(100% + 5px)',
                        top: '-2px'
                      });
                    });

                    jQuery(document).on('click', function(e) {
                      if (!jQuery(e.target).closest('.has-switchbox').length) {
                        $box.hide();
                      }
                    });
                  });

                  (function() {
                    const dropdownTrigger = document.querySelector('.js-picture-dropdown-trigger');
                    const dropdownMenu = document.querySelector('.album-dropdown-menu');

                    if (dropdownTrigger && dropdownMenu) {
                      dropdownTrigger.addEventListener('click', function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        dropdownMenu.classList.toggle('show-menu');
                      });

                      document.addEventListener('click', function(e) {
                        if (!dropdownMenu.contains(e.target) && !dropdownTrigger.contains(e.target)) {
                          dropdownMenu.classList.remove('show-menu');
                        }
                      });
                    }
                  })();

                {/literal}{/footer_script}
                {footer_script require='jquery'}
                {literal}
                  jQuery(function() {
                    var img = document.getElementById('theMainImage');
                    var display = document.querySelector('.macadam-photo-display');
                    if (!img || !display) return;
                    var hasDerivativeCookie = document.cookie.indexOf('picture_deriv=') !== -1;
                    var hasAutomaticCookie = document.cookie.indexOf('macadam_auto_derivative=1') !== -1;
                    if (hasDerivativeCookie && !hasAutomaticCookie) return;

                    var derivatives = [];
                {/literal}
                    {foreach from=$current.unique_derivatives item=derivative key=derivative_type}
                      {if $derivative_type|lower != 'original' && $derivative->get_type()|lower != 'original'}
                        {assign var='derivative_size' value=$derivative->get_size()}
                {literal}
                    derivatives.push({
                      type: '{/literal}{$derivative->get_type()|@escape:'javascript'}{literal}',
                      url: '{/literal}{$derivative->get_url()|@escape:'javascript'}{literal}',
                      width: {/literal}{$derivative_size[0]|intval}{literal},
                      height: {/literal}{$derivative_size[1]|intval}{literal}
                    });
                {/literal}
                      {/if}
                    {/foreach}
                {literal}

                    if (!derivatives.length) return;

                    var availableWidth = display.clientWidth;
                    var availableHeight = window.innerHeight * 0.8;
                    var selected = null;
                    var smallest = derivatives[0];

                    // Use the largest derivative that fits the display width and 80% of the viewport height.
                    derivatives.forEach(function(derivative) {
                      if (derivative.width < smallest.width) {
                        smallest = derivative;
                      }
                      if (derivative.width <= availableWidth &&
                          derivative.height <= availableHeight &&
                          (!selected || derivative.width > selected.width)) {
                        selected = derivative;
                      }
                    });

                    selected = selected || smallest;
                    img.removeAttribute('width');
                    img.removeAttribute('height');
                    img.src = selected.url;
                    img.useMap = '#map' + selected.type;
                    jQuery('#derivativeSwitchBox .switchCheck').css('visibility', 'hidden');
                    jQuery('#derivativeChecked' + selected.type).css('visibility', 'visible');
                    document.cookie = 'picture_deriv=' + selected.type + ';path={/literal}{$COOKIE_PATH}{literal}';
                    document.cookie = 'macadam_auto_derivative=1;path={/literal}{$COOKIE_PATH}{literal}';
                  });
                {/literal}
                {/footer_script}

                <li class="dropdown-item has-switchbox">
                  {strip}
                    <a id="derivativeSwitchLink" title="{'Photo sizes'|@translate}" rel="nofollow">
                      <i class="icon-photo-size"></i> {'Photo sizes'|@translate}
                    </a>
                    <div id="derivativeSwitchBox" class="switchBox">
                      {foreach from=$current.unique_derivatives item=derivative key=derivative_type}
                        {if $derivative_type|lower != 'original' && $derivative->get_type()|lower != 'original'}
                        <span class="switchCheck" id="derivativeChecked{$derivative->get_type()}"
                          {if $derivative->get_type() ne $current.selected_derivative->get_type()} style="visibility:hidden"
                          {/if}><i class="icon-circled-true"></i></span>
                        <a href="javascript:changeImgSrc('{$derivative->get_url()|@escape:javascript}','{$derivative_type}','{$derivative->get_type()}')">
                          {$derivative->get_type()|@translate}
                          <span class="derivativeSizeDetails">({$derivative->get_size_hr()})</span>
                        </a>
                        {/if}
                      {/foreach}
                    </div>
                  {/strip}
                </li>
                {/if}

                {if isset($U_METADATA)}
                  <li class="dropdown-item">
                    <a href="{$U_METADATA}" rel="nofollow">
                      <i class="icon-db"></i> {'Show metadatas'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($current.U_DOWNLOAD)}
                  <li class="dropdown-item resettable-box">
                    {strip}
                      <a id="downloadSwitchLink" href="{$current.U_DOWNLOAD}"
                        rel="nofollow">
                        <i class="icon-add-drive"></i> {'Download'|@translate}
                      </a>
                      {if !empty($current.formats)}
                        {footer_script require='jquery'}
                        {literal}
                          jQuery().ready(function() {
                          jQuery("#downloadSwitchLink").removeAttr("href");
                          (window.SwitchBox=window.SwitchBox||[]).push("#downloadSwitchLink", "#downloadSwitchBox");
                          });
                        {/literal}{/footer_script}
                        <div id="downloadSwitchBox" class="switchBox">
                          <div class="switchBoxTitle">{'Download'|translate} - {'Formats'|translate}</div>
                          <ul>
                            {foreach from=$current.formats item=format}
                              <li><a href="{$format.download_url}" rel="nofollow">{$format.label}<span
                                    class="downloadformatDetails"> ({$format.filesize})</span></a></li>
                            {/foreach}
                          </ul>
                        </div>
                      {/if}
                    {/strip}
                  </li>
                {/if}

                {if isset($favorite)}
                  <li class="dropdown-item">
                    <a href="{$favorite.U_FAVORITE}"
                      rel="nofollow">
                      <i class="icon-heart"></i>
                      {if $favorite.IS_FAVORITE}{'Delete from favorites'|@translate}{else}{'Add to favorites'|@translate}{/if}
                    </a>
                  </li>
                {/if}

                {if isset($U_SET_AS_REPRESENTATIVE)}
                  <li class="dropdown-item">
                    <a id="cmdSetRepresentative" href="{$U_SET_AS_REPRESENTATIVE}" rel="nofollow">
                      <i class="icon-pin"></i> {'Choose as thumbnail'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($U_CADDIE)}
                  {footer_script}
                  {literal}
                    function addToCadie(aElement, rootUrl, id) {
                    if (aElement.disabled) return;
                    aElement.disabled=true;
                    var y = new PwgWS(rootUrl);
                    y.callService("pwg.caddie.add", {image_id: id}, {
                    onFailure: function(num, text) { alert(num + " " + text); document.location=aElement.href; },
                    onSuccess: function(result) { aElement.disabled = false; }
                    });
                    }
                  {/literal}{/footer_script}
                  <li class="dropdown-item">
                    <a href="{$U_CADDIE}" onclick="addToCadie(this, '{$ROOT_URL}', {$current.id}); return false;" rel="nofollow">
                      <i class="icon-banner"></i> {'Add to my selection'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($U_PHOTO_ADMIN)}
                  <li class="dropdown-item admin-edit-link">
                    <a id="cmdEditPhoto" href="{$U_PHOTO_ADMIN}" rel="nofollow">
                      <i class="icon-edit"></i> {'Éditer la photo'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($PLUGIN_PICTURE_BUTTONS) || isset($PLUGIN_PICTURE_ACTIONS)}
                  {if isset($PLUGIN_PICTURE_BUTTONS)}
                    {foreach from=$PLUGIN_PICTURE_BUTTONS item=button}
                      <li class="dropdown-item plugin-injected">{$button}</li>
                    {/foreach}
                  {/if}
                  {if isset($PLUGIN_PICTURE_ACTIONS)}
                    <li class="dropdown-item plugin-injected">{$PLUGIN_PICTURE_ACTIONS}</li>
                  {/if}
                {/if}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="macadam-main-photo-stage">
        <button id="macadam-fullscreen-close-btn">
          <i class="icon-exit-fullscreen"></i>
          <span>ESC</span>
        </button>

        {if isset($previous)}
          <a class="macadam-nav-arrow arrow-left" href="{$previous.U_IMG}">
            <i class="icon-arrow-left"></i>
          </a>
        {else}
          <div class="macadam-nav-arrow arrow-left disabled"><i class="icon-arrow-left"></i></div>
        {/if}

        <div class="macadam-photo-display">
          <div id="theImage">
            {$ELEMENT_CONTENT}
            {if isset($U_SLIDESHOW_STOP)}
              <p>[ <a href="{$U_SLIDESHOW_STOP}">{'stop the slideshow'|@translate}</a> ]</p>
            {/if}
          </div>
        </div>

        {if isset($next)}
          <a class="macadam-nav-arrow arrow-right" href="{$next.U_IMG}">
            <i class="icon-arrow-right"></i>
          </a>
        {else}
          <div class="macadam-nav-arrow arrow-right disabled"><i class="icon-arrow-right"></i></div>
        {/if}
      </div>

      {if isset($MACADAM_THUMBS) && !empty($MACADAM_THUMBS)}
        <div class="carousel-strip-container">
          <div class="macadam-carousel-strip">
            {foreach from=$MACADAM_THUMBS item=thumb}
              {assign var=is_active value=($thumb.id == $current.id)}
              <a class="strip-thumb-item{if $is_active} active{/if}" href="{$thumb.URL}"
                data-full-src="{$thumb.FULL_SRC|escape:'html'}" data-image-id="{$thumb.id}">
                <img src="{$thumb.SRC}" alt="{$thumb.TITLE}">
              </a>
            {/foreach}
          </div>
        </div>
      {/if}

    </div>

    <aside class="macadam-picture-sidebar">
      {if isset($COMMENT_COUNT)}
        <div class="sidebar-tabs">
          <button class="tab-btn active" id="tabInfoLink"><i class="icon-i"></i></button>
          <button class="tab-btn" id="tabCommentsLink"><i class="icon-discuss"></i>
            ({$COMMENT_COUNT})
          </button>
        </div>
      {/if}

      <div class="sidebar-scrollable-content">
        <div id="macadam-sidebar-info-view">
          <div class="sidebar-meta-header">
            <h3 class="photo-title">{$current.TITLE}</h3>
          </div>

          {if isset($COMMENT_IMG)}
            <p class="imageComment">{$COMMENT_IMG}</p>
          {/if}

          {if ($display_info.tags and isset($related_tags))}
            <div class="sidebar-section-tags">
              <div class="tag-badges-container">
                <i class="icon-tags"></i>
                {foreach from=$related_tags item=tag}
                  <a href="{$tag.URL}" class="macadam-tag-badge">{$tag.name}</a>
                {/foreach}
              </div>
            </div>
          {/if}

          <div class="sidebar-section-details">
            <ul class="macadam-info-list">
              {if $display_info.created_on and isset($INFO_CREATION_DATE)}
                <li>
                  <i class="icon-calendar"></i>
                  <span class="info-value">{$INFO_CREATION_DATE}</span>
                </li>
              {/if}
              {if $display_info.posted_on}
                <li>
                  <i class="icon-add-calendar"></i>
                  <span class="info-value">{$INFO_POSTED_DATE}</span>
                </li>
              {/if}
              {if $display_info.filesize and isset($INFO_FILESIZE)}
                <li>
                  <i class="icon-db"></i>
                  <span class="info-value">{$INFO_FILESIZE}</span>
                </li>
              {/if}
              {if $display_info.author and isset($INFO_AUTHOR)}
                <li>
                  <i class="icon-person"></i>
                  <span class="info-value">{$INFO_AUTHOR}</span>
                </li>
              {/if}
              {if $display_info.visits}
                <li>
                  <i class="icon-eye"></i>
                  <span class="info-value">{$INFO_VISITS}</span>
                </li>
              {/if}
              {if $display_info.rating_score and isset($rate_summary)}
                <li>
                  <i class="icon-star"></i>
                  <span class="info-value">
                    {if $rate_summary.count}
                      <span id="ratingScore">{$rate_summary.average}</span> <span
                        id="ratingCount">({$rate_summary.count|@translate_dec:'%d rate':'%d rates'})</span>
                    {else}
                      <span id="ratingScore">{'no rate'|@translate}</span> <span id="ratingCount"></span>
                    {/if}
                  </span>
                  <span class="info-label">/5</span>
                </li>
              {/if}
              {if $display_info.file and isset($display_info.file)}
                <li>
                  <i class="icon-folded-picture"></i>
                  <span class="info-value">{$INFO_FILE}</span>
                </li>
              {/if}
              {if $display_info.categories and isset($related_categories)}
                {foreach from=$related_categories item=cat}
                  <li>
                    <i class="icon-folder"></i>
                    <span class="info-value">{$cat}</span>
                  </li>
                {/foreach}
              {/if}
            </ul>
          </div>

          {if isset($rating)}
            <div class="macadam-rating-box">
              <span id="updateRate" class="rating-title">
                {if isset($rating.USER_RATE)}{'Update your rating'|@translate}{else}{'Rate this photo'|@translate}{/if}
              </span>
              <form action="{$rating.F_ACTION}" method="post" id="rateForm" style="margin-top: 10px;">
                <div class="rating-buttons">
                  {foreach from=$rating.marks item=mark}
                    {if $mark == 0}
                      <label class="rating-reset" title="Clear rating">
                        {if isset($rating.USER_RATE) && $mark==$rating.USER_RATE}
                          <input type="button" name="rate" value="{$mark}" class="rateButtonSelected">
                        {else}
                          <input type="submit" name="rate" value="{$mark}" class="rateButton">
                        {/if}
                        <span class="icon-cross" aria-hidden="true"></span>
                      </label>
                    {else}
                      <label class="rating-star" title="{$mark}">
                        {if isset($rating.USER_RATE) && $mark==$rating.USER_RATE}
                          <input type="button" name="rate" value="{$mark}" class="rateButtonSelected">
                        {else}
                          <input type="submit" name="rate" value="{$mark}" class="rateButton">
                        {/if}
                        <span class="icon-star" aria-hidden="true"></span>
                      </label>
                    {/if}
                  {/foreach}
                </div>
              </form>
            </div>
          {/if}
        </div>

        {if isset($COMMENT_COUNT)}
          <div id="macadam-sidebar-comments-view" style="display: none;">
            <div id="comments">
              <div class="comments-title-bar"
                style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h3 style="margin: 0;">{$COMMENT_COUNT|@translate_dec:'%d comment':'%d comments'}</h3>
                {if isset($comment_add)}
                  <button type="button" id="toggle-comment-form" class="icon-plus comment-toggle-button"
                    aria-label="Add a comment"></button>
                {/if}
              </div>

              {if isset($comment_add)}
                <div id="commentAdd" style="display: none; margin-bottom: 20px;">
                  <h4>{'Add a comment'|@translate}</h4>
                  <form method="post" action="{$comment_add.F_ACTION}" id="addComment">
                    {if $comment_add.SHOW_AUTHOR}
                      <p><label class="comment-field-label" for="author">{'Author'|@translate}{if $comment_add.AUTHOR_MANDATORY} ({'mandatory'|@translate}){/if} :</label>
                        <input type="text" name="author" id="author" value="{$comment_add.AUTHOR}"
                          placeholder="{'Author'|@translate}">
                      </p>
                    {/if}
                    {if $comment_add.SHOW_EMAIL}
                      <p><label class="comment-field-label" for="email">{'Email address'|@translate}{if $comment_add.EMAIL_MANDATORY} ({'mandatory'|@translate}){/if} :</label>
                        <input type="text" name="email" id="email" value="{$comment_add.EMAIL}"
                          placeholder="{'Email address'|@translate}">
                      </p>
                    {/if}
                    {if $comment_add.SHOW_WEBSITE}
                      <p><label class="comment-field-label" for="website_url">{'Website'|@translate} :</label>
                        <input type="text" name="website_url" id="website_url" value="{$comment_add.WEBSITE_URL}"
                          placeholder="{'Website'|@translate}">
                      </p>
                    {/if}
                    <p><label class="comment-field-label" for="contentid">{'Comment'|@translate} ({'mandatory'|@translate}) :</label>
                      <textarea name="content" id="contentid" rows="5"
                        placeholder="{'Comment'|@translate} ({'mandatory'|@translate})">{$comment_add.CONTENT}</textarea>
                    </p>
                    <p>
                      <input type="hidden" name="key" value="{$comment_add.KEY}">
                      <input type="submit" class="submit-comment-btn" value="{'Submit'|@translate}">
                    </p>
                  </form>
                </div>
              {/if}

              <div id="pictureCommentList">
                <div class="comments-list-wrapper">
                  {if isset($COMMENT_LIST)}
                    {$COMMENT_LIST}
                  {/if}
                </div>
              </div>
            </div>
          </div>
        {/if}
      </div>
    </aside>

  </div>
  {if !empty($PLUGIN_PICTURE_AFTER)}{$PLUGIN_PICTURE_AFTER}{/if}
</div>

{footer_script}
{literal}
  document.addEventListener('DOMContentLoaded', function() {

  const tabInfo = document.getElementById('tabInfoLink');
  const tabComments = document.getElementById('tabCommentsLink');
  const viewInfo = document.getElementById('macadam-sidebar-info-view');
  const viewComments = document.getElementById('macadam-sidebar-comments-view');

  if(tabInfo && tabComments) {
  tabInfo.addEventListener('click', function() {
  tabInfo.classList.add('active');
  tabComments.classList.remove('active');
  viewInfo.style.display = 'block';
  viewComments.style.display = 'none';
  });
  tabComments.addEventListener('click', function() {
  tabComments.classList.add('active');
  tabInfo.classList.remove('active');
  viewInfo.style.display = 'none';
  viewComments.style.display = 'block';
  });
  }

  const toggleBtn = document.getElementById('toggle-comment-form');
  const commentForm = document.getElementById('commentAdd');

  if (toggleBtn && commentForm) {
  toggleBtn.addEventListener('click', function(e) {
  e.preventDefault();
  if (commentForm.style.display === 'none' || commentForm.style.display === '') {
  commentForm.style.display = 'block';
  toggleBtn.style.transform = 'rotate(45deg)';
  } else {
  commentForm.style.display = 'none';
  toggleBtn.style.transform = 'rotate(0deg)';
  }
  });
  }

  const fsToggle = document.getElementById('macadam-fullscreen-toggle');
  const fsCloseBtn = document.getElementById('macadam-fullscreen-close-btn');
  const container = document.querySelector('.macadam-picture-container');
  const photoDis = document.querySelector('.macadam-photo-display');
  const theImage = document.getElementById('theImage');
  const navArrowFullscreen = document.querySelectorAll('.macadam-nav-arrow');
  const carouselStrip = document.querySelector('.macadam-carousel-strip');

  const arrowLeft = document.querySelector('.macadam-main-photo-stage .macadam-nav-arrow.arrow-left');
  const arrowRight = document.querySelector('.macadam-main-photo-stage .macadam-nav-arrow.arrow-right');
  const thumbnailItems = Array.from(document.querySelectorAll('.macadam-carousel-strip .strip-thumb-item'));
  let fullscreenImageIndex = thumbnailItems.findIndex(function(item) {
  return item.classList.contains('active');
  });
  let touchStartX = 0;
  let touchStartY = 0;
  let suppressImageClick = false;

  function logFullscreenVisit(imageId) {
  const parsedImageId = parseInt(imageId, 10);
  if (!parsedImageId || typeof jQuery !== 'function') {
  console.error('Unable to log fullscreen image visit: invalid image ID or jQuery unavailable.');
  return;
  }

  jQuery.ajax({
  type: 'POST',
  url: '{/literal}{$ROOT_URL}{literal}ws.php?format=json&method=pwg.history.log',
  data: {
  image_id: parsedImageId
  },
  dataType: 'json',
  error: function(xhr, status, error) {
  console.error('Unable to log fullscreen image visit:', status, error, xhr.responseText);
  }
  });
  }

  function updateFullscreenArrowState() {
  const atFirstImage = fullscreenImageIndex <= 0;
  const atLastImage = fullscreenImageIndex >= thumbnailItems.length - 1;

  navArrowFullscreen.forEach(function(arrow) {
  if (arrow.classList.contains('arrow-left')) {
  arrow.classList.toggle('disabled', atFirstImage);
  } else if (arrow.classList.contains('arrow-right')) {
  arrow.classList.toggle('disabled', atLastImage);
  }
  });
  }

  function changeFullscreenImage(index) {
  if (!document.fullscreenElement || !thumbnailItems.length || !theImage) return false;

  const item = thumbnailItems[index];
  const image = document.getElementById('theMainImage');
  const fullSrc = item && item.dataset.fullSrc;
  if (!item || !image || !fullSrc) return false;

  fullscreenImageIndex = index;
  image.src = fullSrc;
  image.alt = item.querySelector('img') ? item.querySelector('img').alt : image.alt;
  logFullscreenVisit(item.dataset.imageId);
  thumbnailItems.forEach(function(thumbnail) {
  thumbnail.classList.toggle('active', thumbnail === item);
  });
  updateFullscreenArrowState();
  return true;
  }

  function navigateToPrevious() {
  if (document.fullscreenElement) {
  if (fullscreenImageIndex > 0) {
  changeFullscreenImage(fullscreenImageIndex - 1);
  }
  } else if (arrowLeft) {
  arrowLeft.click();
  }
  }

  function navigateToNext() {
  if (document.fullscreenElement) {
  if (fullscreenImageIndex < thumbnailItems.length - 1) {
  changeFullscreenImage(fullscreenImageIndex + 1);
  }
  } else if (arrowRight) {
  arrowRight.click();
  }
  }

  function toggleFullscreen() {
  if (!document.fullscreenElement) {
  container.requestFullscreen()
  .catch(err => console.error("Erreur d'activation : " + err.message));
  } else {
  sessionStorage.removeItem('macadam_persist_fullscreen');
  document.exitFullscreen();
  }
  }

  if (fsToggle && container) {
  fsToggle.addEventListener('click', toggleFullscreen);
  }
  if (fsCloseBtn) {
  fsCloseBtn.addEventListener('click', toggleFullscreen);
  }

  if (carouselStrip) {
  thumbnailItems.forEach(function(thumbnail) {
  thumbnail.addEventListener('click', function() {
  sessionStorage.setItem('macadam_carousel_scroll_left', String(carouselStrip.scrollLeft));
  });
  });
  }

  if (theImage && container) {
    theImage.addEventListener('click', function() {
      if (suppressImageClick) {
        suppressImageClick = false;
        return;
      }
      if (window.innerWidth <= 768) {
        toggleFullscreen();
      }
    });

    theImage.addEventListener('touchstart', function(e) {
      if (!document.fullscreenElement || window.innerWidth > 768 || !e.touches.length) return;
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
    }, { passive: true });

    theImage.addEventListener('touchend', function(e) {
      if (!document.fullscreenElement || window.innerWidth > 768 || !e.changedTouches.length) return;

      const touchEndX = e.changedTouches[0].clientX;
      const touchEndY = e.changedTouches[0].clientY;
      const deltaX = touchEndX - touchStartX;
      const deltaY = touchEndY - touchStartY;

      if (Math.abs(deltaX) < 50 || Math.abs(deltaX) <= Math.abs(deltaY)) return;

      e.preventDefault();
      suppressImageClick = true;
      window.setTimeout(function() {
        suppressImageClick = false;
      }, 500);
      if (deltaX < 0) {
        navigateToNext();
      } else {
        navigateToPrevious();
      }
    }, { passive: false });
  }

  if (arrowLeft) {
  arrowLeft.addEventListener('click', function(e) {
  if (document.fullscreenElement) {
  e.preventDefault();
  navigateToPrevious();
  }
  });
  }
  if (arrowRight) {
  arrowRight.addEventListener('click', function(e) {
  if (document.fullscreenElement) {
  e.preventDefault();
  navigateToNext();
  }
  });
  }

  document.addEventListener('keydown', function(e) {
  if (document.fullscreenElement && container.classList.contains('macadam-in-fullscreen')) {
  if (e.key === 'ArrowLeft') {
  e.preventDefault();
  navigateToPrevious();
  } else if (e.key === 'ArrowRight') {
  e.preventDefault();
  navigateToNext();
  } else if (e.key === 'Escape') {
  e.preventDefault();
  toggleFullscreen();
  }
  }
  });

  document.addEventListener('fullscreenchange', function() {
  if (document.fullscreenElement) {
  container.classList.add('macadam-in-fullscreen');
  photoDis.classList.add('display-in-fullscreen');
  navArrowFullscreen.forEach(arrow => arrow.classList.add('arrow-fullscreen'));
  updateFullscreenArrowState();
  } else {
  container.classList.remove('macadam-in-fullscreen');
  photoDis.classList.remove('display-in-fullscreen');
  navArrowFullscreen.forEach(arrow => arrow.classList.remove('arrow-fullscreen'));
  }
  });

  function reenterFullscreen() {
  if (sessionStorage.getItem('macadam_persist_fullscreen') === 'true' && container) {
  container.requestFullscreen()
  .then(() => {
  sessionStorage.removeItem('macadam_persist_fullscreen');
  })
  .catch(err => console.log("Réactivation en attente d'interaction :", err.message));

  document.removeEventListener('click', reenterFullscreen);
  document.removeEventListener('keydown', reenterFullscreen);
  }
  }

  if (sessionStorage.getItem('macadam_persist_fullscreen') === 'true') {
  document.addEventListener('click', reenterFullscreen);
  document.addEventListener('keydown', reenterFullscreen);
  reenterFullscreen();
  }

  if (carouselStrip) {
  const savedCarouselScrollLeft = sessionStorage.getItem('macadam_carousel_scroll_left');
  if (savedCarouselScrollLeft !== null) {
  carouselStrip.scrollLeft = parseInt(savedCarouselScrollLeft, 10) || 0;
  sessionStorage.removeItem('macadam_carousel_scroll_left');
  }
  }

  });
  
{/literal}
{/footer_script}