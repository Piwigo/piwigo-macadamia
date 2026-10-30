<h3 class="related-tags-title">{'Related tags'|translate}</h3>

{foreach from=$COMBINABLE_TAGS item=tag}
<span class="related-tags {if isset($RELATED_TAGS_DISPLAY) and $RELATED_TAGS_DISPLAY == false} hide{/if}">{strip}
  <a class="tagLevel {if isset($tag.level)}{$tag.level}{/if}" href=
  {if isset($tag.U_ADD)}
    "{$tag.U_ADD}" rel="nofollow">
  {else}
    "{$tag.URL}">
  {/if}
    + {$tag.name}<div class="tag-counter">{$tag.counter}</div></a></span>{/strip}
{/foreach}