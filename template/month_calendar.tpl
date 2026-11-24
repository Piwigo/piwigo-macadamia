<div class="macadam-calendar-wrapper">
  <div class="macadam-calendar-navigation">
    {if isset($MACADAM_POSTED_CALENDAR_URL) && isset($MACADAM_CREATED_CALENDAR_URL)}
      <select id="macadam-calendar-field" class="cal-select-sort"
        onchange="if (this.value) window.location.href = this.value;">
        <option value="{$MACADAM_POSTED_CALENDAR_URL|escape}"
          {if $MACADAM_CALENDAR_FIELD == 'posted'}selected{/if}>
          {'Sort by'|translate} : {'Post date'|translate}
        </option>
        <option value="{$MACADAM_CREATED_CALENDAR_URL|escape}"
          {if $MACADAM_CALENDAR_FIELD == 'created'}selected{/if}>
          {'Sort by'|translate} : {'Creation date'|translate}
        </option>
      </select>
    {/if}

    <div class="cal-date-picker-zone">
      {foreach from=$chronology_navigation_bars item=bar}
        {if isset($bar.previous)}
          <a class="cal-nav-arrow" href="{$bar.previous.URL}"
            aria-label="{$bar.previous.LABEL|escape}"><i class="icon-arrow-left"></i></a>
        {else}
          <a class="cal-nav-arrow"><i class="icon-arrow-left disabled"></i></a>
        {/if}
      {/foreach}
      <div class="cal-current-date">
        <div class="cal-date-selector">
          <button type="button" class="cal-month-menu" aria-expanded="false"
            aria-controls="cal-month-popover">
            {$MACADAM_CALENDAR_MONTH|escape}
            <span class="cal-caret" aria-hidden="true"><i class="icon-arrow-down"></i></span>
          </button>
          <div class="cal-date-popover cal-month-popover" id="cal-month-popover" hidden>
            <div class="cal-date-options">
              {foreach from=$MACADAM_CALENDAR_MONTH_OPTIONS item=option}
                {if $option.selected}
                  <span class="date{if $option.available} date-usable{/if} date-used" aria-current="date">
                    {$option.label|escape}
                  </span>
                {elseif $option.available}
                  <a class="date date-usable" href="{$option.url|escape}">
                    {$option.label|escape}
                  </a>
                {else}
                  <span class="date" aria-disabled="true">{$option.label|escape}</span>
                {/if}
              {/foreach}
            </div>
          </div>
        </div>
        <div class="cal-date-selector">
          <button type="button" class="cal-year-menu" aria-expanded="false"
            aria-controls="cal-year-popover">
            {$MACADAM_CALENDAR_YEAR|escape}
            <span class="cal-caret" aria-hidden="true"><i class="icon-arrow-down"></i></span>
          </button>
          <div class="cal-date-popover cal-year-popover" id="cal-year-popover" hidden>
            <div class="cal-date-options">
              {foreach from=$MACADAM_CALENDAR_YEAR_OPTIONS item=option}
                {if $option.selected}
                  <span class="date{if $option.available} date-usable{/if} date-used" aria-current="date">
                    {$option.label|escape}
                  </span>
                {elseif $option.available}
                  <a class="date date-usable" href="{$option.url|escape}">
                    {$option.label|escape}
                  </a>
                {else}
                  <span class="date" aria-disabled="true">{$option.label|escape}</span>
                {/if}
              {/foreach}
            </div>
          </div>
        </div>
      </div>
      {foreach from=$chronology_navigation_bars item=bar}
        {if isset($bar.next)}
          <a class="cal-nav-arrow" href="{$bar.next.URL}"
            aria-label="{$bar.next.LABEL|escape}"><i class="icon-arrow-right"></i></a>
        {else}
          <a class="cal-nav-arrow"><i class="icon-arrow-right disabled"></i></a>
        {/if}
      {/foreach}
    </div>

    <div class="cal-view-modes" role="group" aria-label="{'View mode'|translate}">
      <a class="cal-btn-mode{if $MACADAM_CALENDAR_ANNUAL_ACTIVE} active{/if}"
        href="{$MACADAM_ANNUAL_CALENDAR_URL|escape}">
        {'Annual'|translate}
      </a>
      <a class="cal-btn-mode{if $MACADAM_CALENDAR_MONTHLY_ACTIVE} active{/if}"
        href="{$MACADAM_MONTHLY_CALENDAR_URL|escape}">
        {'Monthly'|translate}
      </a>
    </div>
  </div>

  {footer_script}
  (function() {
    var selectors = document.querySelectorAll('.cal-date-selector');

    function closePopovers(except) {
      selectors.forEach(function(selector) {
        var popover = selector.querySelector('.cal-date-popover');
        var button = selector.querySelector('button');
        if (popover && popover !== except) {
          popover.hidden = true;
          button.setAttribute('aria-expanded', 'false');
        }
      });
    }

    selectors.forEach(function(selector) {
      var button = selector.querySelector('button');
      var popover = selector.querySelector('.cal-date-popover');
      button.addEventListener('click', function(event) {
        event.stopPropagation();
        var willOpen = popover.hidden;
        closePopovers(popover);
        popover.hidden = !willOpen;
        button.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
      });
      popover.addEventListener('click', function(event) {
        event.stopPropagation();
      });
    });

    document.addEventListener('click', function() {
      closePopovers();
    });
    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape') {
        closePopovers();
      }
    });
  }());
  {/footer_script}

  {if !empty($chronology_calendar.calendar_bars)}
    {foreach from=$chronology_calendar.calendar_bars item=bar}
      <section class="calendar-period">
        <h3><a href="{$bar.U_HEAD}">{$bar.HEAD_LABEL}</a> ({$bar.NB_IMAGES})</h3>
        <div class="calendar-period-items">
          {if isset($bar.items)}
            {foreach from=$bar.items item=item}
              {if isset($item.URL)}
                <a class="calendar-period-item" href="{$item.URL}">
                  {$item.LABEL}
                  {if isset($item.NB_IMAGES)}({$item.NB_IMAGES}){/if}
                </a>
              {else}
                <span class="calendar-period-item current">{$item.LABEL}</span>
              {/if}
            {/foreach}
          {/if}
        </div>

      </section>
    {/foreach}
  {/if}

  {if isset($chronology_calendar.month_view)}
    <table class="macadam-calendar-table" role="grid">
      <tbody>
        {foreach from=$chronology_calendar.month_view.weeks item=week}
          <tr>
            {foreach from=$week item=day}
              {if empty($day)}
                <td class="cal-day-cell outside-month" aria-hidden="true">
                  <div class="cell-header"></div>
                </td>
              {else}
                <td class="cal-day-cell{if isset($day.OUTSIDE_MONTH)} outside-month{/if}{if isset($day.NB_ELEMENTS) && $day.NB_ELEMENTS > 0} has-photos{/if}">
                  {if isset($day.U_IMG_LINK)}
                    <a class="cal-day-background-link" href="{$day.U_IMG_LINK}"
                      aria-label="{$day.NB_ELEMENTS|default:0|translate_dec:'%d photo':'%d photos'}"></a>
                  {/if}
                  <div class="cell-header">
                    {if isset($day.U_IMG_LINK)}
                      <a class="day-number" href="{$day.U_IMG_LINK}">{$day.DAY}</a>
                    {else}
                      <div class="day-number">{$day.DAY}</div>
                    {/if}
                    {if isset($day.U_IMG_LINK) && isset($day.NB_ELEMENTS) && $day.NB_ELEMENTS > 0}
                      <a class="photos-badge" href="{$day.U_IMG_LINK}">
                        {$day.NB_ELEMENTS}
                        {if $day.NB_ELEMENTS == 1}
                          {'photo'|translate}
                        {else}
                          {'photos'|translate}
                        {/if}
                      </a>
                    {/if}
                  </div>

                  {if !empty($day.THUMBNAILS)}
                    <div class="cell-content">
                      <div class="calendar-thumbnail-stack">
                        {foreach from=$day.THUMBNAILS item=thumbnail name=thumbnail_loop}
                          {if $smarty.foreach.thumbnail_loop.last && $day.NB_ELEMENTS > 3}
                            <span class="calendar-thumbnail-last">
                              <a class="calendar-thumbnail" href="{$thumbnail.PICTURE_URL|default:$day.U_IMG_LINK}">
                                <img src="{$thumbnail.URL}"
                                  alt="{$thumbnail.ALT|escape}">
                              </a>
                              <a class="calendar-thumbnail-more" href="{$day.U_IMG_LINK}">
                                <i class="icon-add"></i>
                              </a>
                            </span>
                          {else}
                            <a class="calendar-thumbnail" href="{$thumbnail.PICTURE_URL|default:$day.U_IMG_LINK}">
                              <img src="{$thumbnail.URL}"
                                alt="{$thumbnail.ALT|escape}">
                            </a>
                          {/if}
                        {/foreach}
                      </div>
                    </div>
                  {/if}
                </td>
              {/if}
            {/foreach}
          </tr>
        {/foreach}
      </tbody>
    </table>
  {/if}
</div>
