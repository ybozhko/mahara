{auto_escape off}
    <p id="lastminutes">({str tag="lastminutes" args=$sbdata.lastminutes})</p>
    <h3>{str tag="onlineusers" args=$sbdata.count}</h3>
    <div class="sideblock-content">
        <ul class="cr">
{foreach from=$sbdata.users item=user}
            <li><a href="{$WWWROOT}user/view.php?id={$user->id|escape}"><div class="image-container"><img src="{$user->profileiconurl|escape}" alt=""></div>{$user|display_name|escape}</a>{if $user->loggedinfrom} ({$user->loggedinfrom|escape}){/if}</li>
{/foreach}
        </ul>
    </div>
{/auto_escape}