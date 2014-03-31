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
define('NOSESSKEY', 1);

require(dirname(dirname(__FILE__)) . '/init.php');
require('lib.php');

$q = param_alphanum('q');

// Filter defaults.
$accesstypes = ArtefactType::default_accesstypes();
$default = array_filter($accesstypes, function($el) use ($q) {
    return (strpos(strtolower($el['name']), $q) !== false);
});

$users = get_records_sql_array("SELECT 'usr|' || id AS id, id AS usrid, firstname, lastname FROM {usr}
                WHERE firstname " . db_ilike() . " '%{$q}%' OR lastname " . db_ilike() . " '%{$q}%'
                      AND id != 0
                ORDER BY lastname, firstname
                DESC LIMIT 10", array());

if (!$users) {
    $users = array();
} else {
    foreach ($users as $key => $value) {
        $users[$key]->name = display_name($value->usrid, $USER);
    }
}

$groups = get_records_sql_array("SELECT 'group|' || id AS id, name FROM {group}
                WHERE name " . db_ilike() . " '%{$q}%' AND public = 1
                ORDER BY name
                DESC LIMIT 5", array());

if (!$groups) {
    $groups = array();
}

$institutions = get_records_sql_array("SELECT 'institution|' || name AS id, displayname as name FROM {institution}
                WHERE displayname " . db_ilike() . " '%{$q}%' AND name != 'mahara'
                ORDER BY displayname
                DESC LIMIT 5", array());

if (!$institutions) {
    $institutions = array();
}

$total = array_merge($default, $users, $groups, $institutions);

json_headers();
echo json_encode($total);
