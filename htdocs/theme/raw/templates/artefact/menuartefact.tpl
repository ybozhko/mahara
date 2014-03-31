{if $enablecomments}
  <a id="add_feedback_link" class="feedback" href="">{str tag=placefeedback section=artefact.comment}</a>
{/if}
{if $LOGGEDIN}
  <a id="objection_link" class="objection" href="">{str tag=reportobjectionablematerial section=view}</a>
{/if}
<a id="print_link" class="print" href="" onclick="window.print(); return false;">{str tag=print section=view}</a>
