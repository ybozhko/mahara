{auto_escape off}
{if $microheaders}{include file="viewmicroheader.tpl"}{else}{include file="header.tpl"}{/if}
<h1>{$maintitle}</h1>

<div class="center">
    <p>{str tag=changeviewtheme section=view}</p>
    <form action="{$formurl}" method="post">
        <input type="hidden" id="viewid" name="id" value="{$view}">
        <label for="viewtheme-select">{str tag=theme}: </label>
        <select id="viewtheme-select" name="viewtheme">
            <option value="">Choose theme...</option>
{foreach from=$viewthemes key=themeid item=themename}
            <option value="{$themeid|escape}"{if $themeid == $viewtheme} selected="selected" style="font-weight: bold;"{/if}>{$themename|escape}</option>
{/foreach}
        </select>
        <input type="submit" class="submit" value="{str tag=submit}">
    </form>
</div>

{if $microheaders}{include file="microfooter.tpl"}{else}{include file="footer.tpl"}{/if}
{/auto_escape}