<input type="hidden" name="accesslist" value="">
<div id="editaccesswrap">
<div class="fl presets-container">
  <div id="potentialpresetitems">
    <h3 class="title">{{str tag=sharewith section=view}}</h3>
  </div>
  <fieldset id="viewacl-advanced" class="collapsible collapsed">
    <legend><a href="" id="viewacl-advanced-show">{{str tag=otherusersandgroups section=view}}</a></legend>
      <div class="viewacl-advanced-search">
        <label>{{str tag=search}}</label>
        <select name="type" id="type">
          <option value="friend" selected="selected">{{str tag=friends section=view}}</option>
          <option value="group">{{str tag=groups}}</option>
          <option value="user">{{str tag=users}}</option>
        </select>
        <input type="text" name="search" id="search">
        <button id="dosearch" class="btn-search" type="button">{{str tag=go}}</button>
      </div>
      <table id="results">
          <tbody>
          </tbody>
      </table>
  </fieldset>
</div>

<table id="accesslisttable" class="fr hidden fullwidth hidefocus" tabindex="-1">
  <thead>
    <tr class="accesslist-head">
      <th><span class="accessible-hidden">{{str tag=profileicon section=view}}</span></th>
      <th>{{str tag=Added section=view}}</th>
      <th>{{str tag=startdate section=view}}</th>
      <th>{{str tag=stopdate section=view}}</th>
      <th class="center comments{{if $allowcomments}} hidden{{/if}}">{{str tag=Comments section=artefact.comment}}</th>
      <th><span class="accessible-hidden">{{str tag=edit}}</span></th>
    </tr>
  </thead>
  <tbody id="accesslistitems">
  </tbody>
</table>

<table id="accesslisttabledefault" class="fr hidden fullwidth hidefocus" tabindex="-1">
  <thead>
    <tr class="accesslist-head">
      <th>{{str tag=Added section=view}}</th>
    </tr>
  </thead>
  <tbody id="accesslistitems">
    <tr>
      <td>{{str tag=defaultaccesslistmessage section=view}}</td>
    </tr>
  </tbody>
</table>

<div class="cb"></div>
</div>
<script type="text/javascript">
var count = 0;

// Utility functions

// Given a row, render it on the left hand side
function renderPotentialPresetItem(item) {
    var accessString;
    if (item.type == 'group' || item.type == 'institution') {
        accessString = get_string('addaccess' + item.type, item.name);
    }
    else {
        accessString = get_string('addaccess', item.name);
    }
    var addButton = BUTTON({'type': 'button'}, accessString);
    var attribs = {};
    if (item.preset) {
        attribs = {'class': 'preset'};
    }
    else if (item['class']) {
        attribs = {'class': item['class']};
    }

    var row = DIV(attribs, addButton, ' ', item.shortname ? SPAN({'title':item.name}, item.shortname) : item.name);
    item.preset = true;

    if (item.type == 'allgroups') {
        connect(addButton, 'onclick', function() {
            var rows = [];
            forEach(myGroups, function(g) {
                rows.push(renderAccessListItem(g));
            });
            if (rows.length > 0) {
                getFirstElementByTagAndClassName('input', null, rows[0]).focus();
            }
        });
    }
    else {
        connect(addButton, 'onclick', function() {
            var row = renderAccessListItem(item);
            getFirstElementByTagAndClassName('input', null, row).focus();
        });
    }
    appendChildNodes('potentialpresetitems', row);

    return row;
}

function renderAccessListDefault() {
    addElementClass('accesslisttable', 'hidden');
    removeElementClass('accesslisttabledefault', 'hidden');
}

// Given a row, render it on the right hand side
function renderAccessListItem(item) {
    var removeButton = BUTTON({'type': 'button', 'title': {{jstr tag=remove}}});
    var allowfdbk = INPUT({
                        'type': 'checkbox',
                        'name': 'accesslist[' + count + '][allowcomments]',
                        'id'  :  'allowcomments' + count,
                        'value':  1});
    var allowfdbklabel = LABEL({'for': 'allowcomments' + count}, get_string('Allow'));
    var approvefdbk = INPUT({
                        'type': 'checkbox',
                        'name': 'accesslist[' + count + '][approvecomments]',
                        'id'  :  'approvecomments' + count,
                        'value':  1});
    var approvefdbklabel = LABEL({'for': 'approvecomments' + count}, get_string('Moderate'));

    if (item['allowcomments']==1) {
        setNodeAttribute(allowfdbk,'checked',true);
        if (item['approvecomments'] == 1) {
            setNodeAttribute(approvefdbk, 'checked', true);
        }
    }
    else {
        setNodeAttribute(approvefdbk, 'disabled', true);
    }
    connect(allowfdbk, 'onclick', function() {
        if (allowfdbk.checked) {
            approvefdbk.disabled = false;
        }
        else {
            approvefdbk.disabled = true;
            approvefdbk.checked = false;
        }
    });
    var cssClass = 'ai-container';
    if (item.preset) {
        cssClass += '  preset';
    }
    cssClass += ' ' + item.type + '-container';
    var name = [item.shortname ? SPAN({'title': item.name}, item.shortname) : item.name];
    if (item.role != null) {
        name.push(' - ', item.roledisplay);
    }
    var icon = null;
    if (item.type == 'user') {
        icon = IMG({'src': config.wwwroot + 'thumb.php?type=profileicon&id=' + item.id + '&maxwidth=25&maxheight=25'});
    }

    // if this item is 'public' and public pages are disabled
    // change the background colour and add some contextual help
    if (item.accesstype == 'public' && !item.publicallowed) {
        cssClass += ' item-disabled';

        var helpText = SPAN({'class': 'page-help-icon'}, SPAN({'class': 'help'}, contextualHelpIcon('', '', 'core', 'view', 'publicaccessrevoked', '')));
        name.push(helpText);
    }

    var notpublicorallowed = (item.accesstype != 'public' || item.publicallowed);

    var row = TR({'class': cssClass, 'id': 'accesslistitem' + count},
        TD({'class': 'icon-container'}, icon),
        TD({'class': 'accesslistname'}, name),
        TD(null, makeCalendarInput(item, 'start', notpublicorallowed), makeCalendarLink(item, 'start', notpublicorallowed)),
        TD(null, makeCalendarInput(item, 'stop', notpublicorallowed), makeCalendarLink(item, 'stop', notpublicorallowed)),
        TD({'class': 'center comments' + (allowcomments ? ' hidden' : '')}
            , allowfdbk, allowfdbklabel, ' ', approvefdbk, approvefdbklabel),
        TD({'class': 'right removebutton'}, removeButton,
            INPUT({
                'type': 'hidden',
                'name': 'accesslist[' + count + '][type]',
                'value': item.type
            }),
            (item.id ?
            INPUT({
                'type': 'hidden',
                'name': 'accesslist[' + count + '][id]',
                'value': item.id
            })
            :
            null
            ),
            (item.role != null ?
            INPUT({
                'type': 'hidden',
                'name': 'accesslist[' + count + '][role]',
                 'value': item.role
            })
            :
            null
            )
        )
    );

    connect(removeButton, 'onclick', function() {
        removeElement(row);
        if (!getFirstElementByTagAndClassName('tr', null, 'accesslistitems')) {
            renderAccessListDefault();
            $('accesslisttabledefault').focus();
        }
        else {
            $('accesslisttable').focus();
        }
        // Update the formchangechecker state
        if (typeof formchangemanager !== 'undefined') {
            formchangemanager.setFormStateById('{{$formname}}', FORM_CHANGED);
        }
    });
    appendChildNodes('accesslistitems', row);
    addElementClass('accesslisttabledefault', 'hidden');
    removeElementClass('accesslisttable', 'hidden');

    if (notpublicorallowed) {
        setupCalendar(item, 'start');
        setupCalendar(item, 'stop');
    }

    if (item.locked) {
        // Remove buttons
        $j(row).find('button').remove();

        // Disable date inputs
        $j(row).find("input[name*='startdate']").attr('disabled', 'disabled');
        $j(row).find("input[name*='stopdate']").attr('disabled', 'disabled');
        $j(row).find('.pieform-calendar-toggle').hide();
    }
    count++;
    // Update the formchangechecker state
    if (typeof formchangemanager !== 'undefined') {
        formchangemanager.setFormStateById('{{$formname}}', FORM_CHANGED);
    }

    return row;
}

function makeCalendarInput(item, type, disabled) {
    var label = LABEL({
        'for': type + 'date_' + count,
        'class': 'accessible-hidden'
    }, get_string(type + 'date'));
    var input = INPUT({
        'type':'text',
        'name': 'accesslist[' + count + '][' + type + 'date]',
        'id'  :  type + 'date_' + count,
        'value': item[type + 'date'] ? item[type + 'date'] : '',
        'size': '15'
    });

    input.disabled = (disabled == 0);

    return SPAN(null, label, input);
}

function makeCalendarLink(item, type) {
    var link = A({
        'href'   : '',
        'id'     : type + 'date_' + count + '_btn',
        'onclick': 'return false;', // @todo do with mochikit connect
        'class'  : 'pieform-calendar-toggle'},
        IMG({
            'src': '{{theme_url filename='images/btn_calendar.png'}}',
            'alt': get_string('element.calendar.opendatepicker', 'pieforms')})
    );

    return link;
}

function setupCalendar(item, type) {
    //log(type);
    var dateStatusFunc, selectedFunc;
    //if (type == 'start') {
    //    dateStatusFunc = function(date) {
    //        startDateDisallowed(date, $(item.id + '_stopdate'));
    //    };
    //    selectedFunc = function(calendar, date) {
    //        startSelected(calendar, date, $(item.id + '_startdate'), $(item.id + '_stopdate'));
    //    }
    //}
    //else {
    //    dateStatusFunc = function(date) {
    //        stopDateDisallowed(date, $(item.id + '_startdate'));
    //    };
    //    selectedFunc = function(calendar, date) {
    //        stopSelected(calendar, date, $(item.id + '_startdate'), $(item.id + '_stopdate'));
    //    }
    //}
    if (!$(type + 'date_' + count)) {
        logWarn('Couldn\'t find element: ' + type + 'date_' + count);
        return;
    }
    Calendar.setup({
        "ifFormat"  :{{jstr tag=strftimedatetimeshort}},
        "daFormat"  :{{jstr tag=strftimedatetimeshort}},
        "inputField": type + 'date_' + count,
        "button"    : type + 'date_' + count + '_btn',
        //"dateStatusFunc" : dateStatusFunc,
        //"onSelect"       : selectedFunc
        "onUpdate"  : updateFormChangeChecker,
        "showsTime" : true
    });
}

function updateFormChangeChecker() {
    if (typeof formchangemanager !== 'undefined') {
        formchangemanager.setFormStateById('{{$formname}}', FORM_CHANGED);
    }
}

// SETUP

// Left top: public, loggedin, friends
var potentialPresets = {{$potentialpresets|safe}};
forEach(potentialPresets, function(preset) {
    renderPotentialPresetItem(preset);
});
var myInstitutions = {{$myinstitutions|safe}};
if (myInstitutions.length) {
    appendChildNodes('potentialpresetitems', H3({'class': 'title'}, '{{str tag=sharewithmyinstitutions section=view}}'));
    var i = 0;
    var maxInstitutions = 5;
    forEach(myInstitutions, function(preset) {
        if (i == maxInstitutions) {
            var more = A({'href':''}, '{{str tag=moreinstitutions section=view}} »');
            connect(more, 'onclick', function(e) {
                e.stop();
                forEach(getElementsByTagAndClassName('div', 'moreinstitutions', 'potentialpresetitems'), partial(toggleElementClass, 'hidden'));
            });
            appendChildNodes('potentialpresetitems', DIV(null, ' ', more));
        }
        if (i >= maxInstitutions) {
            preset['class'] = 'hidden moreinstitutions';
        }
        renderPotentialPresetItem(preset);
        i++;
    });

}
var allGroups = {{$allgroups|safe}};
var myGroups = {{$mygroups|safe}};
if (myGroups) {
    appendChildNodes('potentialpresetitems', H3({'class': 'title'}, {{jstr tag=sharewithmygroups section=view}}));
    renderPotentialPresetItem(allGroups);
    var i = 0;
    var maxGroups = 10;
    forEach(myGroups, function(preset) {
        if (i == maxGroups) {
            var more = A({'href':''}, {{jstr tag=moregroups section=group}} + ' »');
            connect(more, 'onclick', function(e) {
                e.stop();
                forEach(getElementsByTagAndClassName('div', 'moregroups', 'potentialpresetitems'), partial(toggleElementClass, 'hidden'));
            });
            appendChildNodes('potentialpresetitems', DIV(null, ' ', more));
        }
        if (i >= maxGroups) {
            preset['class'] = 'hidden moregroups';
        }
        renderPotentialPresetItem(preset);
        i++;
    });
}
var faves = {{$faves|safe}};
if (faves) {
    appendChildNodes('potentialpresetitems', H3({'class': 'title'}, {{jstr tag=sharewithusers section=view}}));
    forEach(faves, renderPotentialPresetItem);
}
var loggedinindex = {{$loggedinindex}};
function ensure_loggedin_access() {
    var oldaccess = getFirstElementByTagAndClassName(null, 'loggedin-container', 'accesslistitems');
    if (oldaccess) {
        forEach(getElementsByTagAndClassName(null, 'loggedin-container', 'accesslistitems'), function (elem) {
            if (oldaccess != elem) {
                removeElement(elem);
            }
        });
    }
    else {
        renderAccessListItem(potentialPresets[loggedinindex]);
    }
    var newaccess = getFirstElementByTagAndClassName(null, 'loggedin-container', 'accesslistitems');
    addElementClass(getFirstElementByTagAndClassName(null, 'removebutton', newaccess), 'hidden');
    forEach(getElementsByTagAndClassName(null, 'pieform-calendar-toggle', newaccess), function (elem) { addElementClass(elem, 'hidden'); });
    forEach(getElementsByTagAndClassName('input', null, newaccess), function (elem) {
        if (elem.name.match(/\[st(art|op)date\]$/)) {
            elem.value = '';
            elem.disabled = true;
        }
    });
}
function relax_loggedin_access() {
    forEach(getElementsByTagAndClassName(null, 'loggedin-container', $('accesslistitems')), function (elem) {
        removeElementClass(getElementsByTagAndClassName(null, 'removebutton', elem)[0], 'hidden');
        forEach(getElementsByTagAndClassName(null, 'pieform-calendar-toggle', elem), function (elem1) { removeElementClass(elem1, 'hidden'); });
        forEach(getElementsByTagAndClassName('input', null, elem), function (elem1) { elem1.disabled = false; });
    });
}

// Left hand side
var searchTable = new TableRenderer(
    'results',
    'access.json.php',
    [
        undefined, undefined, undefined
    ]
);
searchTable.statevars.push('type');
searchTable.statevars.push('query');
searchTable.type = 'friend';
searchTable.pagerOptions = {
    'firstPageString': '\u00AB',
    'previousPageString': '<',
    'nextPageString': '>',
    'lastPageString': '\u00BB',
    'linkOptions': {
        'href': '',
        'style': 'padding-left: 0.5ex; padding-right: 0.5ex;'
    }
}
searchTable.query = '';
searchTable.rowfunction = function(rowdata, rownumber, globaldata) {
    rowdata.type = searchTable.type;
    rowdata.type = rowdata.type == 'friend' ? 'user' : rowdata.type;

    var buttonTD = TD({'class': 'buttontd'});

    var addButton = BUTTON({'type': 'button', 'class': 'button'}, {{jstr tag=add}});
    connect(addButton, 'onclick', function() {
        appendChildNodes('accesslist', renderAccessListItem(rowdata));
    });
    appendChildNodes(buttonTD, addButton);

    var identityNodes = [], profileIcon = null, roleSelector = null;
    if (rowdata.type == 'user') {
        profileIcon = IMG({'src': config.wwwroot + 'thumb.php?type=profileicon&maxwidth=25&maxheight=25&id=' + rowdata.id});
        identityNodes.push(A({'href': rowdata.url, 'target': '_blank'}, rowdata.name));
    }
    else if (rowdata.type == 'group') {
        rowdata.role = null;
        var options = [OPTION({'value':null, 'selected':true}, {{jstr tag=everyoneingroup section=view}})];
        for (r in globaldata.roles[rowdata.grouptype]) {
            options.push(OPTION({'value':globaldata.roles[rowdata.grouptype][r].name}, globaldata.roles[rowdata.grouptype][r].display));
        }
        roleSelector = SELECT({'name':'role'}, options);
        connect(roleSelector, 'onchange', function() {
            rowdata.role = this.value;
            if (this.value) {
                rowdata.roledisplay = scrapeText(this.childNodes[this.selectedIndex]);
            }
        });
        identityNodes.push(A({'href': rowdata.url, 'target': '_blank'}, rowdata.name));
        identityNodes.push(" - ");
        identityNodes.push(roleSelector);
    }

    return TR({'class': 'r' + (rownumber % 2)},
        buttonTD,
        TD({'class': 'sharewithusersname'}, identityNodes),
        TD({'class': 'right icon-container'}, profileIcon)
    );
}
searchTable.updateOnLoad();

function search(e) {
    searchTable.query = $('search').value;
    searchTable.type  = $('type').options[$('type').selectedIndex].value;
    searchTable.doupdate();
    e.stop();
}


// Right hand side
addLoadEvent(function () {
    {{if $defaultaccesslist}}
    renderAccessListDefault();
    {{else}}
    var accesslist = {{$accesslist|safe}};
    if (accesslist) {
        forEach(accesslist, function(item) {
            renderAccessListItem(item);
        });
    }
    {{/if}}
    update_loggedin_access();
});

addLoadEvent(function() {
    // Populate the "potential access" things (public|loggedin|allfreidns)

    connect($('search'), 'onkeydown', function(e) {
        if (e.key().string == 'KEY_ENTER') {
            search(e);
        }
    });
    connect($('dosearch'), 'onclick', search);
    connect('viewacl-advanced-show', 'onclick', function(e) {
        e.stop();
        toggleElementClass('collapsed', 'viewacl-advanced');
    });
});

</script>
