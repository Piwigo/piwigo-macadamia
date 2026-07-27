{combine_script id='core.switchbox' load='async' require='jquery' path='themes/default/js/switchbox.js'}
{if isset($MENUBAR)}{$MENUBAR}{/if}

<div id="content" {if isset($MENUBAR)} class="contentWithMenu" {/if}>

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

            <button class="dropdown-trigger-btn" title="Options">
              <i class="icon-wheel"></i>
            </button>

            <ul class="dropdown-menu-list">
              <i class=" icon-arrow-left"></i>
              <div class="dropdown-menu-lst-inner">
                {if isset($current.unique_derivatives) && count($current.unique_derivatives)>1}
                  {footer_script require='jquery'}
                  {literal}
                    function changeImgSrc(url,typeSave,typeMap) {
                    var theImg = document.getElementById("theMainImage");
                    if (theImg) {
                    theImg.removeAttribute("width"); theImg.removeAttribute("height");
                    theImg.src = url;
                    theImg.useMap = "#map"+typeMap;
                    }
                    jQuery('#derivativeSwitchBox .switchCheck').css('visibility','hidden');
                    jQuery('#derivativeChecked'+typeMap).css('visibility','visible');
                    document.cookie = 'picture_deriv='+typeSave+';path={/literal}{$COOKIE_PATH}{literal}';
                    }
                    (window.SwitchBox=window.SwitchBox||[]).push(".dropdown-item.has-switchbox #derivativeSwitchLink",
                    ".dropdown-item.has-switchbox #derivativeSwitchBox");
                  {/literal}{/footer_script}

                  <li class="dropdown-item has-switchbox">
                    {strip}
                      <a id="derivativeSwitchLink" title="{'Photo sizes'|@translate}" rel="nofollow">
                        <i class="icon-photo-size"></i> {'Photo sizes'|@translate}
                      </a>
                      <div id="derivativeSwitchBox" class="switchBox">
                        <div class="switchBoxTitle">{'Photo sizes'|@translate}</div>
                        {foreach from=$current.unique_derivatives item=derivative key=derivative_type}
                          <span class="switchCheck" id="derivativeChecked{$derivative->get_type()}"
                            {if $derivative->get_type() ne $current.selected_derivative->get_type()} style="visibility:hidden"
                            {/if}>&#x2714; </span>
                          <a
                            href="javascript:changeImgSrc('{$derivative->get_url()|@escape:javascript}','{$derivative_type}','{$derivative->get_type()}')">
                            {$derivative->get_type()|@translate}<span class="derivativeSizeDetails">
                              ({$derivative->get_size_hr()})</span>
                          </a><br>
                        {/foreach}
                        {if isset($U_ORIGINAL)}
                          {combine_script id='core.scripts' load='async' path='themes/default/js/scripts.js'}
                          <a href="javascript:phpWGOpenWindow('{$U_ORIGINAL}','xxx','scrollbars=yes,toolbar=no,status=no,resizable=yes')"
                            rel="nofollow">{'Original'|@translate}</a>
                        {/if}
                      </div>
                    {/strip}
                  </li>
                {/if}

                {if isset($U_METADATA)}
                  <li class="dropdown-item">
                    <a href="{$U_METADATA}" title="{'Show file metadata'|@translate}" rel="nofollow">
                      <i class="icon-db"></i> {'Show metadatas'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($current.U_DOWNLOAD)}
                  <li class="dropdown-item resettable-box">
                    {strip}
                      <a id="downloadSwitchLink" href="{$current.U_DOWNLOAD}" title="{'Download this file'|@translate}"
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
                      title="{if $favorite.IS_FAVORITE}{'delete this photo from your favorites'|@translate}{else}{'add this photo to your favorites'|@translate}{/if}"
                      rel="nofollow">
                      <i class="icon-heart"></i>
                      {if $favorite.IS_FAVORITE}{'Delete from favorites'|@translate}{else}{'Add to favorites'|@translate}{/if}
                    </a>
                  </li>
                {/if}

                {if isset($U_SET_AS_REPRESENTATIVE)}
                  <li class="dropdown-item">
                    <a id="cmdSetRepresentative" href="{$U_SET_AS_REPRESENTATIVE}"
                      title="{'set as album representative'|@translate}" rel="nofollow">
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
                    <a href="{$U_CADDIE}" onclick="addToCadie(this, '{$ROOT_URL}', {$current.id}); return false;"
                      title="{'Add to caddie'|@translate}" rel="nofollow">
                      <i class="icon-banner"></i> {'Add to my selection'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($U_PHOTO_ADMIN)}
                  <li class="dropdown-item admin-edit-link">
                    <a id="cmdEditPhoto" href="{$U_PHOTO_ADMIN}" title="{'Edit photo'|@translate}" rel="nofollow">
                      <i class="icon-edit"></i> {'Éditer la photo'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($PLUGIN_PICTURE_BUTTONS) || isset($PLUGIN_PICTURE_ACTIONS)}
                  <li class="dropdown-divider"></li>
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
            </ul>
          </div>
        </div>
      </div>

      <div class="macadam-main-photo-stage">
        <button id="macadam-fullscreen-close-btn" title="Quitter le plein écran">
          <i class="icon-exit-fullscreen"></i>
          <span>ESC</span>
        </button>

        {if isset($previous)}
          <a class="macadam-nav-arrow arrow-left" href="{$previous.U_IMG}" title="{'Previous'|@translate}">
            <span>‹</span>
          </a>
        {else}
          <div class="macadam-nav-arrow arrow-left disabled"><span>‹</span></div>
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
          <a class="macadam-nav-arrow arrow-right" href="{$next.U_IMG}" title="{'Next'|@translate}">
            <span>›</span>
          </a>
        {else}
          <div class="macadam-nav-arrow arrow-right disabled"><span>›</span></div>
        {/if}
      </div>

      {if isset($MACADAM_THUMBS) && !empty($MACADAM_THUMBS)}
        <div class="carousel-strip-container">
          <div class="macadam-carousel-strip">
            {if isset($previous)}
              <a class="macadam-nav-arrow arrow-mobile arrow-left" href="{$previous.U_IMG}" title="{'Previous'|@translate}">
                <span>‹</span>
              </a>
            {else}
              <div class="macadam-nav-arrow arrow-mobile arrow-left disabled"><span>‹</span></div>
            {/if}
            {foreach from=$MACADAM_THUMBS item=thumb}
              {assign var=is_active value=($thumb.id == $current.id)}
              <a class="strip-thumb-item{if $is_active} active{/if}" href="{$thumb.URL}" title="{$thumb.TITLE}">
                <img src="{$thumb.SRC}" alt="{$thumb.TITLE}">
              </a>
            {/foreach}
            {if isset($next)}
              <a class="macadam-nav-arrow arrow-mobile arrow-right" href="{$next.U_IMG}" title="{'Next'|@translate}">
                <span>›</span>
              </a>
            {else}
              <div class="macadam-nav-arrow  arrow-mobile arrow-right disabled"><span>›</span></div>
            {/if}
          </div>
        </div>
      {/if}

    </div>

    <aside class="macadam-picture-sidebar">
      {if isset($COMMENT_COUNT)}
        <div class="sidebar-tabs">
          <button class="tab-btn active" id="tabInfoLink" title="Informations"><i class="icon-i"></i></button>
          <button class="tab-btn" id="tabCommentsLink" title="Commentaires"><i class="icon-discuss"></i>
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
                      <span id="ratingScore">{$rate_summary.score}</span> <span
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
              <form action="{$rating.F_ACTION}" method="post" id="rateForm">
                <div class="rating-buttons">
                  {foreach from=$rating.marks item=mark}
                    {if isset($rating.USER_RATE) && $mark==$rating.USER_RATE}
                      <input type="button" name="rate" value="{$mark}" class="rateButtonSelected" title="{$mark}">
                    {else}
                      <input type="submit" name="rate" value="{$mark}" class="rateButton" title="{$mark}">
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
                  <button type="button" id="toggle-comment-form" class="icon-plus"
                    style="background: none; border: none; cursor: pointer; font-size: 1.1rem; padding: 5px; color: #1e293b; transition: transform 0.2s ease; display: flex; align-items: center; justify-content: center;"></button>
                {/if}
              </div>

              {if isset($comment_add)}
                <div id="commentAdd" style="display: none; margin-bottom: 20px;">
                  <form method="post" action="{$comment_add.F_ACTION}" id="addComment">
                    {if $comment_add.SHOW_AUTHOR}
                      <p><label for="author">{'Author'|@translate}:</label>
                        <input type="text" name="author" id="author" value="{$comment_add.AUTHOR}">
                      </p>
                    {/if}
                    {if $comment_add.SHOW_EMAIL}
                      <p><label for="email">{'Email address'|@translate}:</label>
                        <input type="text" name="email" id="email" value="{$comment_add.EMAIL}">
                      </p>
                    {/if}
                    <p><label for="contentid">{'Comment'|@translate}:</label>
                      <textarea name="content" id="contentid" rows="4">{$comment_add.CONTENT}</textarea>
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
  const navArrowFullscreen = document.querySelectorAll('.macadam-nav-arrow');

  const arrowLeft = document.querySelector('.macadam-nav-arrow.arrow-left:not(.disabled)');
  const arrowRight = document.querySelector('.macadam-nav-arrow.arrow-right:not(.disabled)');

  function navigateToPrevious() {
  if (arrowLeft) {
  if (document.fullscreenElement) {
  sessionStorage.setItem('macadam_persist_fullscreen', 'true');
  }
  arrowLeft.click();
  }
  }

  function navigateToNext() {
  if (arrowRight) {
  if (document.fullscreenElement) {
  sessionStorage.setItem('macadam_persist_fullscreen', 'true');
  }
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

  if (theImage && container) {
    theImage.addEventListener('click', function() {
      if (window.innerWidth <= 768) {
        toggleFullscreen();
      }
    });
  }

  if (arrowLeft) {
  arrowLeft.addEventListener('click', function() {
  if (document.fullscreenElement) sessionStorage.setItem('macadam_persist_fullscreen', 'true');
  });
  }
  if (arrowRight) {
  arrowRight.addEventListener('click', function() {
  if (document.fullscreenElement) sessionStorage.setItem('macadam_persist_fullscreen', 'true');
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

  const activeThumb = document.querySelector('.macadam-carousel-strip .strip-thumb-item.active');
  if (activeThumb) {
  setTimeout(() => {
  activeThumb.scrollIntoView({
  behavior: 'smooth',
  block: 'nearest',
  inline: 'center'
  });
  }, 100);
  }
  });
  
{/literal}
{/footer_script}