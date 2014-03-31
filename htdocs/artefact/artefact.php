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
define('SECTION_PAGE', 'artefact');

require(dirname(dirname(__FILE__)) . '/init.php');
require_once(get_config('docroot') . 'artefact/lib.php');
require_once(get_config('libroot') . 'view.php');
safe_require('artefact', 'comment');

$artefactid = param_integer('artefact');
$path       = param_variable('path', null);

$artefact = artefact_instance_from_id($artefactid);

if (!can_view_artefact($artefact)) {
    throw new AccessDeniedException();
}

$title = $artefact->display_title();
define('TITLE', get_string('Artefact', 'mahara') . ": " . $title);

// Build the path to the artefact, through its parents.
$artefactpath = array();
$parent = $artefact->get('parent');
$artefactok = true;
$baseobject = $artefact;

while ($parent !== null) {
    // This loop could get expensive when there are a lot of parents.
    $parentobj = artefact_instance_from_id($parent);
        array_unshift($artefactpath, array(
            'url'   => get_config('wwwroot') . 'artefact/artefact.php?artefact=' . $parent,
            'title' => $parentobj->display_title(),
        ));

    $parent = $parentobj->get('parent');
    if (can_view_artefact($parentobj->get('id'))) {
        $artefactok = true;
        $baseobject = $parentobj;
    }
}
if ($artefactok == false) {
    throw new AccessDeniedException();
}

// Feedback list pagination requires limit/offset params.
$limit       = param_integer('limit', 10);
$offset      = param_integer('offset', 0);
$showcomment = param_integer('showcomment', null);

// Create the "make feedback private form" now if it's been submitted.
if (param_variable('make_public_submit', null)) {
    pieform(ArtefactTypeComment::make_public_form(param_integer('comment')));
}
else if (param_variable('delete_comment_submit_x', null)) {
    pieform(ArtefactTypeComment::delete_comment_form(param_integer('comment')));
}

// Render the artefact.
$options = array(
    'viewid' => null,
    'path' => $path,
    'details' => true,
    'metadata' => 1,
);

$rendered = $artefact->render_self($options);
$content = '';
if (!empty($rendered['javascript'])) {
    $content = '<script type="text/javascript">' . $rendered['javascript'] . '</script>';
}
$content .= $rendered['html'];

$artefactpath[] = array(
    'url' => '',
    'title' => $title,
);

$headers = array('<link rel="stylesheet" type="text/css" href="' . get_config('wwwroot') . 'theme/views.css?v=' . get_config('release'). '">',);

// Feedback.
$view = null;
$feedback = ArtefactTypeComment::get_comments($limit, $offset, $showcomment, $view, $artefact);

$inlinejavascript = <<<EOF
var viewid = null;
var artefactid = {$artefactid};
addLoadEvent(function () {
    paginator = {$feedback->pagination_js}
});
EOF;

$javascript = array('paginator', 'expandable');
$extrastylesheets = array();

if ($artefact->get('allowcomments')) {
    $addfeedbackform = pieform(ArtefactTypeComment::add_comment_form(false, $artefact->get('approvecomments')));
    $extrastylesheets[] = 'style/jquery.rating.css';
    $javascript[] = 'jquery.rating';
}
$objectionform = pieform(objection_form());

$smarty = smarty($javascript, $headers, array(), array('stylesheets' => $extrastylesheets));
$smarty->assign('artefact', $content);
$smarty->assign('artefactpath', $artefactpath);
$smarty->assign('INLINEJAVASCRIPT', $inlinejavascript);
$smarty->assign('feedback', $feedback);

if (isset($addfeedbackform)) {
    $smarty->assign('enablecomments', 1);
    $smarty->assign('addfeedbackform', $addfeedbackform);
}
$smarty->assign('objectionform', $objectionform);
$smarty->display('artefact/artefact.tpl');
