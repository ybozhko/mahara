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

// To use in forms:
// 'ELEMENTNAME'  => array(
//      'type'         => 'autocomplete',
//      'title'        => TEXT,
//      'ajax'         => get_config('wwwroot') . '/LOCATION',
//      'defaultvalue' => null, // Or some value.
//      'description'  => TEXT,      // Optional.
//      'theme'        => THEMENAME, // Optional.
//      'hint'         => HINTTEXT,  // Optional.
//      'allowadding'  => true,      // Optional, defaults to false.
// ),

defined('INTERNAL') || die();

/**
 * Autocomplete list selector element
 *
 * @param array    $element The element to render
 * @param Pieform  $form    The form to render the element for
 * @return string           The HTML for the element
 */
function pieform_element_autocomplete(Pieform $form, $element) {
    $wwwroot = get_config('wwwroot');
    $smarty = smarty_core();

    $smarty->left_delimiter = '{{';
    $smarty->right_delimiter = '}}';

    $value = $form->get_value($element);

    if (!is_array($value) && isset($element['defaultvalue']) && is_array($element['defaultvalue'])) {
        $value = $element['defaultvalue'];
    }

    if ($tempvalue = $form->get_value($element)) {
        $value = $tempvalue;
    }

    if (isset($element['value']) && is_array($element['value'])) {
        $value = $element['value'];
    }

    if (!is_array($value)) {
        $value = array();
    }

    if (!isset($element['size'])) {
        $element['size'] = 60;
    }

    if (!isset($element['allowadding'])) {
        $element['allowadding'] = false;
    }

    if (!isset($element['hint'])) {
        $element['hint'] = get_string('sharewithhint');
    }

    $smarty->assign('id', $form->get_name() . '_' . $element['id']);
    $smarty->assign('name', $element['name']);
    $smarty->assign('value', json_encode($value)); // Pre-populate form element.
    $smarty->assign('ajax', $wwwroot . $element['ajax']);
    $smarty->assign('size', $element['size']);
    $smarty->assign('hint', $element['hint']);
    $smarty->assign('allowadding', $element['allowadding']);
    if (isset($element['theme'])) {
        $smarty->assign('theme', $element['theme']);
    }
    if (isset($element['description'])) {
        $smarty->assign('describedby', $form->element_descriptors($element));
    }

    return $smarty->fetch('form/autocomplete.tpl');
}

/**
 * Returns code to go in <head> for the given autocomplete instance
 *
 * @param array $element The element to get <head> code for
 * @return array         An array of HTML elements to go in the <head>
 */
function pieform_element_autocomplete_get_headdata($element) {
    $wwwroot = get_config('wwwroot');
    $libfile = $wwwroot . 'js/jquery.tokeninput.js';

    $result = array(
        '<script type="text/javascript" src="' . $libfile . '?v=' . get_config('release'). '"></script>',
    );
    return $result;
}

/**
 * Returns value for the given autocomplete instance
 */
function pieform_element_autocomplete_get_value(Pieform $form, $element) {
    $global = ($form->get_property('method') == 'get') ? $_GET : $_POST;

    if (isset($element['value'])) {
        $values = $element['value'];
    }
    else if ($form->is_submitted() && isset($global[$element['name']])) {
        $values = $global[$element['name']];
    }
    else if (!$form->is_submitted() && isset($element['defaultvalue'])) {
        return $element['defaultvalue'];
    }
    else {
        $values = array();
    }

    if ($values == '' || empty($values)) {
        return array();
    }
    else {
        $results = explode(',', $values);
        return $results;
    }

    return null;
}
