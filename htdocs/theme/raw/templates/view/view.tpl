{auto_escape off}
{if $microheaders}{include file="viewmicroheader.tpl"}{else}{include file="header.tpl"}{/if}

{if $maintitle}<h1>{$maintitle}</h1>{/if}

{if !$microheaders && $mnethost}
<div class="rbuttons">
  <a href="{$mnethost.url}">{str tag=backto arg1=$mnethost.name}</a>
</div>
{/if}

<p id="view-description">{$viewdescription}</p>

<div id="view" class="cb">
        <div id="bottom-pane">
            <div id="column-container">
               {$viewcontent}
                <div class="cb">
                </div>
            </div>
        </div>
  <div class="viewfooter cb">
    {if $tags}<div class="tags">{str tag=tags}: {list_tags owner=$owner tags=$tags}</div>{/if}
    <div>{$releaseform}</div>
    {if $view_group_submission_form}<div>{$view_group_submission_form}</div>{/if}
    {if $feedback->count || $enablecomments}
    <table id="feedbacktable" class="fullwidth table">
      <thead><tr><th>{str tag="feedback" section="artefact.comment"}</th></tr></thead>
      <tbody>
        {$feedback->tablerows}
      </tbody>
    </table>
    {$feedback->pagination}
    {/if}
	<div id="viewmenu">
        {include file="view/viewmenu.tpl" enablecomments=$enablecomments}
    </div>
    {if $addfeedbackform}<div>{$addfeedbackform}</div>{/if}
    {if $objectionform}<div>{$objectionform}</div>{/if}
  </div>
</div>
{if $visitstring}<div class="ctime center s">{$visitstring}</div>{/if}

{if $microheaders}{include file="microfooter.tpl"}{else}{include file="footer.tpl"}{/if}{/auto_escape}