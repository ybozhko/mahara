<?php
/**
 *
 * @package    mahara
 * @subpackage artefact
 * @author     Yuliya Bozhko <yuliya.bozhko@totaralms.com>
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL version 3 or later
 * @copyright  For copyright information on Mahara, please see the README file distributed with this software.
 *
 */

define('INTERNAL', 1);
define('MENUITEM', 'content');
define('SECTION_PLUGINTYPE', 'artefact');
define('SECTION_PLUGINNAME', 'artefact');
define('SECTION_PAGE', 'index');

require(dirname(dirname(__FILE__)) . '/init.php');

define('TITLE', get_string('Artefacts', 'mahara'));

$type    = param_variable('type', '');  // Type of artefact to load.
$ownerid = param_integer('usr', null);  // User id.
$offset  = param_integer('offset', 0);  // Offset for pagination.
$limit   = param_integer('limit', 20);  // Limit for pagination.

$userid = $USER->get('id');

$artefacts = ArtefactType::get_artefacts($type, $userid, $ownerid, $offset, $limit);
ArtefactType::build_artefacts_list_html($artefacts);

$js = <<< EOF
addLoadEvent(function() {
    {$artefacts['pagination_js']}
});
EOF;

$smarty = smarty(array('paginator'));
$smarty->assign_by_ref('artefacts', $artefacts);
$smarty->assign('strnoartefacts', get_string('noartefacts', 'mahara'));
$smarty->assign('PAGEHEADING', hsc(get_string('Artefacts', 'mahara')));
$smarty->assign('INLINEJAVASCRIPT', $js);
$smarty->display('artefact/index.tpl');
