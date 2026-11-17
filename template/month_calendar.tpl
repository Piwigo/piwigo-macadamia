{if true}
  <div class="macadam-calendar-wrapper">
    <div class="macadam-calendar-navigation">
      <form method="get" action="{$chronology_calendar.U_VIEW|default:''}">
        <input type="hidden" name="page" value="{$chronology_calendar.page|default:''}">
        <input type="hidden" name="year" value="{$chronology_calendar.year|default:''}">
        <input type="hidden" name="month" value="{$chronology_calendar.month|default:''}">

        <label class="sr-only" for="{$chronology_calendar.field_sort|default:'sort'}">{'Sort by'|translate}</label>
        <select id="{$chronology_calendar.field_sort|default:'sort'}" class="cal-select-sort" onchange="if (this.value) window.location.href = this.value;">
          <option value="{$MACADAM_POSTED_CALENDAR_URL|escape}" {if $MACADAM_CALENDAR_FIELD == 'posted'}selected{/if}>{'Post date'|translate}</option>
          <option value="{$MACADAM_CREATED_CALENDAR_URL|escape}" {if $MACADAM_CALENDAR_FIELD == 'created'}selected{/if}>{'Creation date'|translate}</option>
        </select>
      </form>

      <div class="cal-date-picker-zone">
        <a class="cal-nav-arrow" href="{$chronology_calendar.U_PREV|default:'#'}" aria-label="{'Previous'|translate}"><</a>

        <div class="cal-current-date" aria-label="{'Selected date'|translate}">
        
          <span class="cal-month">
            {$chronology_calendar.month_name|default:$macadam_cal_fallback_month_name|default:($chronology_calendar.month|default:($smarty.get.month|default:''))}
          </span>
          <span class="cal-year">
            {$chronology_calendar.year|default:$macadam_cal_fallback_year|default:$smarty.get.year|default:''}
          </span>
          <span class="cal-caret">▾</span>
        </div>

        <a class="cal-nav-arrow" href="{$chronology_calendar.U_NEXT|default:'#'}" aria-label="{'Next'|translate}">></a>
      </div>

      <div class="cal-view-modes" role="group" aria-label="{'View mode'|translate}">
        <a class="cal-btn-mode{if $chronology_calendar.month_mode == 'annual'} active{/if}" href="{$chronology_calendar.U_ANNUAL|default:'#'}">Annual</a>
        <a class="cal-btn-mode{if $chronology_calendar.month_mode == 'monthly'} active{/if}" href="{$chronology_calendar.U_MONTHLY|default:'#'}">Monthly</a>
      </div>
    </div>

    <table class="macadam-calendar-table" role="grid">
      <thead>
        <tr>
{if isset($chronology_calendar.days_of_week) && $chronology_calendar.days_of_week|@count > 0}
          {foreach from=$chronology_calendar.days_of_week item=d}
            <th>{$d}</th>
          {/foreach}
        {else}
          {for $i=0 to 6}<th></th>{/for}
        {/if}
        </tr>
      </thead>

      <tbody>
        {if !empty($chronology_calendar.weeks)}
          {foreach from=$chronology_calendar.weeks item=week}
            <tr>
              {foreach from=$week item=day}
                {assign var="cell_outside" value=$day.outside_month|default:false}
                <td class="cal-day-cell{if $cell_outside} outside-month{/if}{if !empty($day.photos_count)} has-photos{/if}">

                  <div class="cell-header">
                    <div class="day-number">{$day.day_number}</div>

                    {if isset($day.photos_count) && $day.photos_count|intval > 0}
                      {assign var="count" value=$day.photos_count|intval}
                      <a class="photos-badge" href="{$day.U_DAY|default:'#'}">{$count} {if $count == 1}photo{else}photos{/if}</a>
                    {/if}
                  </div>

                  <div class="cell-content">
                    <div class="thumb-preview-stack" aria-hidden="true">
                      {if isset($day.preview_colors) && $day.preview_colors|@count > 0}
                        {assign var="shown" value=0}
                        {foreach from=$day.preview_colors item=c}
                          {if $shown < 3}
                            <span class="color-block {$c.class}"></span>
                            {$shown = $shown + 1}
                          {/if}
                        {/foreach}

                        {if isset($day.photos_count) && $day.photos_count|intval > 3}
                          <span class="color-block block-dark more-thumb">
                            <span class="more-circle">+</span>
                          </span>
                        {/if}
                      {else}
                        <span class="color-block block-orange" style="opacity:.2"></span>
                        <span class="color-block block-beige" style="opacity:.2"></span>
                        <span class="color-block block-dark" style="opacity:.2"></span>
                      {/if}
                    </div>
                  </div>

                </td>
              {/foreach}
            </tr>
          {/foreach}
        {else}
          {* Quand le mois n'est pas correctement initialisé, on évite un message brut et on affiche juste la grille *}
          {if isset($chronology_calendar.days_of_week) && $chronology_calendar.days_of_week|@count > 0}
            {for $r=0 to 5}
              <tr>
{foreach from=$chronology_calendar.days_of_week item=_d name=dayloop}
                  <td class="cal-day-cell outside-month" aria-hidden="true">
                    <div class="cell-header">
                      <div class="day-number">{assign var="_dnum" value=$r*7+{$smarty.foreach.dayloop.iteration|default:0}+1}{$_dnum}</div>
                    </div>
                    <div class="cell-content">
                      <div class="thumb-preview-stack" aria-hidden="true">
                        <span class="color-block block-orange" style="opacity:.1"></span>
                        <span class="color-block block-beige" style="opacity:.1"></span>
                        <span class="color-block block-dark" style="opacity:.1"></span>
                      </div>
                    </div>
                  </td>
                {/foreach}
              </tr>
            {/for}
          {else}
            {* Si même days_of_week est absent: tenter un rendu minimal (6x7) *}
            {for $r=0 to 5}
              <tr>
                {for $c=0 to 6}
                  <td class="cal-day-cell outside-month" aria-hidden="true">
                    <div class="cell-header">
                      <div class="day-number"></div>
                    </div>
                    <div class="cell-content">
                      <div class="thumb-preview-stack" aria-hidden="true">
                        <span class="color-block block-orange" style="opacity:.1"></span>
                        <span class="color-block block-beige" style="opacity:.1"></span>
                        <span class="color-block block-dark" style="opacity:.1"></span>
                      </div>
                    </div>
                  </td>
                {/for}
              </tr>
            {/for}
          {/if}
        {/if}
      </tbody>
    </table>

  </div>
{/if}
