{foreach from=$artefacts.data item=artefact}
    <div class="{cycle values='r0,r1'} listrow">
        {$artefact->html|safe}
    </div>
{/foreach}
