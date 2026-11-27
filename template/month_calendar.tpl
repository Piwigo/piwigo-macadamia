{combine_script id='macadam.calendar' load='footer' path='themes/macadamia/js/calendar.js'}

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
      {if $MACADAM_CALENDAR_ANNUAL_ACTIVE}
        {if isset($MACADAM_CALENDAR_PREVIOUS_YEAR_URL)}
          <a class="cal-nav-arrow" href="{$MACADAM_CALENDAR_PREVIOUS_YEAR_URL|escape}"
            aria-label="{'Previous'|translate} {$MACADAM_CALENDAR_PREVIOUS_YEAR|escape}"><i class="icon-arrow-left"></i></a>
        {else}
          <a class="cal-nav-arrow"><i class="icon-arrow-left disabled"></i></a>
        {/if}
      {else}
        {foreach from=$chronology_navigation_bars item=bar}
          {if isset($bar.previous)}
            <a class="cal-nav-arrow" href="{$bar.previous.URL}"
              aria-label="{$bar.previous.LABEL|escape}"><i class="icon-arrow-left"></i></a>
          {else}
            <a class="cal-nav-arrow"><i class="icon-arrow-left disabled"></i></a>
          {/if}
        {/foreach}
      {/if}
      <div class="cal-current-date">
        {if !$MACADAM_CALENDAR_ANNUAL_ACTIVE}
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
                    <a class="date date-usable date-used" href="{$option.url|escape}" aria-current="date">
                      {$option.label|escape}
                    </a>
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
        {/if}
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
                  <a class="date date-usable date-used" href="{$option.url|escape}" aria-current="date">
                    {$option.label|escape}
                  </a>
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
      {if $MACADAM_CALENDAR_ANNUAL_ACTIVE}
        {if isset($MACADAM_CALENDAR_NEXT_YEAR_URL)}
          <a class="cal-nav-arrow" href="{$MACADAM_CALENDAR_NEXT_YEAR_URL|escape}"
            aria-label="{'Next'|translate} {$MACADAM_CALENDAR_NEXT_YEAR|escape}"><i class="icon-arrow-right"></i></a>
        {else}
          <a class="cal-nav-arrow"><i class="icon-arrow-right disabled"></i></a>
        {/if}
      {else}
        {foreach from=$chronology_navigation_bars item=bar}
          {if isset($bar.next)}
            <a class="cal-nav-arrow" href="{$bar.next.URL}"
              aria-label="{$bar.next.LABEL|escape}"><i class="icon-arrow-right"></i></a>
          {else}
            <a class="cal-nav-arrow"><i class="icon-arrow-right disabled"></i></a>
          {/if}
        {/foreach}
      {/if}
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

  {if !empty($chronology_calendar.calendar_bars)}
    <div class="calendar-year-months">
    {foreach from=$chronology_calendar.calendar_bars item=bar}
      <section class="calendar-period">
        <h3>
          {if isset($bar.U_HEAD)}
            <a href="{$bar.U_HEAD|escape}">{$bar.HEAD_LABEL|escape}</a>
          {else}
            {$bar.HEAD_LABEL|escape}
          {/if}
        </h3>
        {if isset($bar.calendar_weeks)}
          <table class="calendar-month-grid">
            <thead>
              <tr>
                {foreach from=$MACADAM_CALENDAR_WEEKDAYS item=weekday}
                  <th scope="col"><abbr title="{$weekday|escape}">{$weekday|truncate:1:""|escape}</abbr></th>
                {/foreach}
              </tr>
            </thead>
            <tbody>
              {foreach from=$bar.calendar_weeks item=week}
                <tr>
                  {foreach from=$week item=day}
                    <td class="calendar-month-day{if $day.NB_IMAGES < 0} outside-month{elseif $day.NB_IMAGES > 0} has-photos{/if}">
                      {if $day.NB_IMAGES < 0}
                        <span class="calendar-month-day-number">{$day.DAY}</span>
                      {elseif isset($day.URL)}
                        <a class="calendar-month-day-link" href="{$day.URL|escape}">
                          <span class="calendar-month-day-number">{$day.DAY}</span>
                        </a>
                      {else}
                        <span class="calendar-month-day-number">{$day.DAY}</span>
                      {/if}
                    </td>
                  {/foreach}
                </tr>
              {/foreach}
            </tbody>
          </table>
        {/if}
      </section>
    {/foreach}
    </div>
  {/if}

  {if isset($chronology_calendar.month_view) && empty($MACADAM_CALENDAR_HAS_MONTH_GRIDS)}
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
