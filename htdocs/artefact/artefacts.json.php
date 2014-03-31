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
define('JSON', 1);

require(dirname(dirname(__FILE__)) . '/init.php');
require('lib.php');

$type   = param_variable('type', '');
$ownerid = param_integer('usr', null);  // User id.
$offset = param_integer('offset', 0);
$limit  = param_integer('limit', 20);

$userid = $USER->get('id');

$artefacts = ArtefactType::get_artefacts($type, $userid, $ownerid, $offset, $limit);
ArtefactType::build_artefacts_list_html($artefacts);

json_reply(false, array('data' => $artefacts));
