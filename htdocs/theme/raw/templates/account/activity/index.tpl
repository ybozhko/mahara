{auto_escape off}
{include file="header.tpl"}

			<div id="notifications">
			<form method="post">
			<label>{str section='activity' tag='type'}:</label>
			<select id="notifications_type" name="type">
				<option value="all">--</option>
			{foreach from=$options item=name key=t}
				<option value="{$t}"{if $type == $t} selected{/if}>{$name}</option>
			{/foreach}
			</select>{contextualhelp plugintype='core' pluginname='activity' section='activitytypeselect'}
			</form>
			<form name="notificationlist" method="post" onSubmit="{$markread}">
			<table id="activitylist" class="fullwidth">
				<thead>
					<tr>
						<th width="10"></th>
						<th>{str section='activity' tag='subject'}</th>
						<th width="60">{str section='activity' tag='date'}</th>
						<th width="50" class="center">{str section='activity' tag='read'}<br><a href="" onclick="{$selectallread}">{str section='activity' tag='selectall'}</a></th>
						<th width="50" class="center">{str tag='delete'}<br><a href="" onclick="{$selectalldel}">{str section='activity' tag='selectall'}</a></th>
					</tr>
				</thead>
                <tfoot>
				  	<tr>
						<td colspan="5" class="right">
						  <input class="submit" type="submit" value="{str tag='markasread' section='activity'}" />
						  <input class="submit btn-delete" type="button" value="{str tag='delete'}" onClick="{$markdel}" />
						</td>
				  	</tr>
				</tfoot>
				<tbody>
                {$activitylist.tablerows}
                </tbody>
			</table>
            {$activitylist.pagination}
			</form>
			</div>
            <div class="left">{$deleteall}</div>
			
{include file="footer.tpl"}
{/auto_escape}