    {if $foruminfo}
        <table class="fullwidth s listing">
        {foreach from=$foruminfo item=postinfo}
            <tr class="{cycle values='r0,r1'}">
                <td><strong><a href="{$WWWROOT}interaction/forum/topic.php?id={$postinfo->topic|escape}#post{$postinfo->id}">{$postinfo->topicname}</a></strong></td>
                <td>{$postinfo->body|str_shorten_html:100:true|safe}</td>
                <td><img src="{$WWWROOT}thumb.php?type=profileicon&amp;maxsize=20&amp;id={$postinfo->poster}" alt="">
                    <a href="{$WWWROOT}user/view.php?id={$postinfo->poster}">{$postinfo->poster|display_name|escape}</a>
                </td>
            </tr>
        {/foreach}
        </table>
    {else}
        <p>{str tag=noforumpostsyet section=interaction.forum}</p>
    {/if}
    <div class="right"><a href="{$WWWROOT}interaction/forum/?group={$group->id}">{str tag=gotoforums section=interaction.forum} &raquo;</a></div>