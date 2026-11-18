{combine_script id='core.switchbox' load='async' require='jquery' path='themes/default/js/switchbox.js'}
{combine_script id='macadam.picture' load='footer' require='jquery' path='themes/macadam/js/picture.js'}
{combine_script id='macadam.picture-fullscreen' load='footer' path='themes/macadam/js/picture-fullscreen.js'}
{if isset($MENUBAR)}{$MENUBAR}{/if}

<div id="content">

  {if isset($errors) or not empty($infos)}
    {include file='infos_errors.tpl'}
  {/if}

  {if !empty($PLUGIN_PICTURE_BEFORE)}{$PLUGIN_PICTURE_BEFORE}{/if}

  <div class="macadam-picture-container" data-root-url="{$ROOT_URL|escape:'html'}" data-cookie-path="{$COOKIE_PATH|escape:'html'}">

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



                <li class="dropdown-item has-switchbox">
                  {strip}
                    <a id="derivativeSwitchLink" title="{'Photo sizes'|@translate}" rel="nofollow">
                      <i class="icon-photo-size"></i> {'Photo sizes'|@translate}
                    </a>
                    <div id="derivativeSwitchBox" class="switchBox">
                      {foreach from=$current.unique_derivatives item=derivative key=derivative_type}
                        {if $derivative_type|lower != 'original' && $derivative->get_type()|lower != 'original'}
                        {assign var='derivative_size' value=$derivative->get_size()}
                        <span class="switchCheck" id="derivativeChecked{$derivative->get_type()}"
                          {if $derivative->get_type() ne $current.selected_derivative->get_type()} style="visibility:hidden"
                          {/if}><i class="icon-circled-true"></i></span>
                        <a href="#" class="macadam-derivative-link"
                          data-url="{$derivative->get_url()|escape:'html'}"
                          data-save="{$derivative_type|escape:'html'}"
                          data-type="{$derivative->get_type()|escape:'html'}"
                          data-width="{$derivative_size[0]|intval}"
                          data-height="{$derivative_size[1]|intval}">
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

                  <li class="dropdown-item">
                    <a href="{$U_CADDIE}" class="js-add-to-caddie" data-image-id="{$current.id}" rel="nofollow">
                      <i class="icon-banner"></i> {'Add to my selection'|@translate}
                    </a>
                  </li>
                {/if}

                {if isset($U_PHOTO_ADMIN)}
                  <li class="dropdown-item admin-edit-link">
                    <a id="cmdEditPhoto" href="{$U_PHOTO_ADMIN}" rel="nofollow">
                      <i class="icon-edit"></i> {'Edit picture'|@translate}
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
                <li id="ratingInfo">
                  <i class="icon-star"></i>
                  <span class="info-value">
                    {if $rate_summary.count}
                      <span id="ratingScore">{$rate_summary.average}/5</span>
                    {else}
                      <span id="ratingScore">{'no rate'|@translate}</span>
                    {/if}
                  </span>
                  {if isset($rating)}
                    <span class="open-rating-form" id="openRatingForm">
                      {if isset($rating.USER_RATE)}<i class="icon-edit"></i> {'Update your rating'|@translate}{else}<i class="icon-add"></i> {'Rate this photo'|@translate}{/if}
                    </span>
                    
                    <form action="{$rating.F_ACTION}" method="post" id="interactiveRateForm" class="interactive-rating-form">
                      <input type="hidden" name="rate" id="interactiveRateValue" value="">
                      <div class="interactive-rating-stars" role="radiogroup" aria-label="{'Rate this photo'|@translate}">
                        {for $star=1 to 5}
                          <button type="button" class="interactive-rating-star" data-rating="{$star}" aria-label="{$star}/5">
                            <i class="icon-star-empty" aria-hidden="true"></i>
                          </button>
                        {/for}
                      </div>
                      <div class="interactive-rating-actions">
                        <button type="submit" class="interactive-rating-submit"><i class="icon-circled-true"></i></button>
                        <button type="button" class="interactive-rating-close"><i class="icon-cross"></i></button>
                      </div>
                    </form>
                  {/if}
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
<style>
.arrow-mobile,
.macadam-header-search{
  display: none !important;
}
</style>