{include file="header.tpl"}
<div id="artefactswrap">
{if !$artefacts.data}
    <div class="message">{$strnoartefacts|safe}</div>
{else}
    <div id="artefactlist" class="fullwidth listing">{$artefacts.tablerows|safe}</div>
   {$artefacts.pagination|safe}
{/if}
</div>
{include file="footer.tpl"}