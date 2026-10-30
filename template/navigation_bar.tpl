{if !empty($navbar)}
  <nav class="macadam-pagination">
    {if isset($navbar.URL_PREV)}
      <a class="macadam-pagination-button" href="{$navbar.URL_PREV}" rel="prev">
        <i class="icon-arrow-left"></i>{'Previous abbreviation'|@translate}
      </a>
    {else}
      <span class="macadam-pagination-button is-disabled" aria-disabled="true">
        <i class="icon-arrow-left"></i>{'Previous abbreviation'|@translate}
      </span>
    {/if}

    {capture name=page_select}<select class="macadam-pagination-select"
        aria-label="{'Page %s of %s'|@translate:$navbar.CURRENT_PAGE:$navbar.NB_PAGE}">
        {foreach from=$navbar.pages key=page item=url}
          <option value="{$url}" {if $page == $navbar.CURRENT_PAGE} selected="selected" {/if}>{$page}</option>
        {/foreach}
    </select>{/capture}

    <div class="macadam-pagination-page">
      {'Page %s of %s'|@translate:$smarty.capture.page_select:$navbar.NB_PAGE}
    </div>

    {if isset($navbar.URL_NEXT)}
      <a class="macadam-pagination-button" href="{$navbar.URL_NEXT}" rel="next">
        {'Next abbreviation'|@translate}<i class="icon-arrow-right"></i>
      </a>
    {else}
      <span class="macadam-pagination-button is-disabled" aria-disabled="true">
        {'Next abbreviation'|@translate}<i class="icon-arrow-right"></i>
      </span>
    {/if}
  </nav>

  {footer_script}
  document.querySelectorAll('.macadam-pagination-select').forEach(function(select) {
  select.addEventListener('change', function() {
  if (this.value) {
  window.location.href = this.value;
  }
  });
  });
  {/footer_script}
{/if}