{include file="header.tpl"}

        <h2>
            {str tag="Artefact"}{foreach from=$artefactpath item=a}:
                {if $a.url}<a href="{$a.url}">{/if}{$a.title}{if $a.url}</a>{/if}
            {/foreach}
        </h2>

        <div id="view">
            <div id="bottom-pane">
                <div id="column-container">
                {$artefact|safe}
                </div>
            </div>
        </div>

      <div class="viewfooter cb">
        {if $feedback->count || $enablecomments}
        <h3 class="title">{str tag="feedback" section="artefact.comment"}</h3>
        <div id="feedbacktable" class="fullwidth">
            {$feedback->tablerows|safe}
        </div>
        {$feedback->pagination|safe}
        {/if}
        <div id="viewmenu">
            {include file="artefact/menuartefact.tpl"}
        </div>
        <div>{$addfeedbackform|safe}</div>
        <div>{$objectionform|safe}</div>
      </div>

{include file="footer.tpl"}