<?php
/**
 * Mahara: Electronic portfolio, weblog, resume builder and social networking
 * Copyright (C) 2006-2011 Catalyst IT Ltd and others; see:
 *                         http://wiki.mahara.org/Contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @package    mahara
 * @subpackage blocktype-taggedposts
 * @author     Catalyst IT Ltd
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL
 * @copyright  (C) 2011 Catalyst IT Ltd http://catalyst.net.nz
 *
 */

defined('INTERNAL') || die();

class PluginBlocktypeTaggedposts extends SystemBlocktype {

    public static function get_title() {
        return get_string('title', 'blocktype.taggedposts');
    }

    public static function get_description() {
        return get_string('description', 'blocktype.taggedposts');
    }

    public static function get_categories() {
        return array('blog');
    }

    public static function render_instance(BlockInstance $instance, $editing=false) {
        global $USER;

        $configdata = $instance->get('configdata');
        $view = $instance->get('view');
        $limit = isset($configdata['count']) ? (int) $configdata['count'] : 10;
        $results = '';

        $smarty = smarty_core();
        $smarty->assign('view', $view);

        // Display all posts, from all blogs, owned by this user
        if (!empty($configdata['tagselect'])) {
            $tagselect = $configdata['tagselect'];

            $sql =
                'SELECT a.title, p.title AS parenttitle, a.id, a.parent, a.owner, at.tag
                FROM {artefact} a
                JOIN {artefact} p ON a.parent = p.id
                JOIN {artefact_blog_blogpost} ab ON (ab.blogpost = a.id AND ab.published = 1)
                JOIN {artefact_tag} at ON (at.artefact = a.id)
                WHERE a.artefacttype = \'blogpost\'
                AND a.owner = (SELECT "owner" from {view} WHERE id = ?)
                AND at.tag = ?
                ORDER BY a.ctime DESC
                LIMIT ?';

            $results = get_records_sql_array($sql, array($view, $tagselect, $limit));

            // if posts are not found with the selected tag, notify the user
            if (!$results) {
                $smarty->assign('badtag', $tagselect);
                return $smarty->fetch('blocktype:taggedposts:taggedposts.tpl');
            }

            // update the view_artefact table so journal entries are accessible when this is the only block on the page
            // referencing this journal
            $dataobject = array(
                'view'      => $view,
                'block'     => $instance->get('id'),
            );

            foreach ($results as $result) {
                $dataobject["artefact"] = $result->parent;
                ensure_record_exists('view_artefact', $dataobject, $dataobject);
            }

            // check if the user viewing the page is the owner of the selected tag
            $owner = $results[0]->owner;
            if ($USER->id != $owner) {
                $sql =
                    'SELECT id, firstname, lastname
                    FROM {usr}
                    WHERE id = ?';

                $viewowner = get_records_sql_array($sql, array($owner));

                $smarty->assign('viewowner', $viewowner);
            }

            $smarty->assign('tag', $tagselect);
        }
        else {
            // error if block configuration fails
            $smarty->assign('configerror', true);
            return $smarty->fetch('blocktype:taggedposts:taggedposts.tpl');
        }

        $smarty->assign('results', $results);
        return $smarty->fetch('blocktype:taggedposts:taggedposts.tpl');
    }

    public static function has_instance_config() {
        return true;
    }

    public static function instance_config_form($instance) {
        $configdata = $instance->get('configdata');

        $tags = get_my_tags(null, false);

        $options = array();
        if (!empty($tags)) {
            foreach ($tags as $tag) {
                $options[$tag->tag] = $tag->tag;
            }
            return array(
                'tagselect' => array(
                    'type'          => 'radio',
                    'title'         => get_string('taglist','blocktype.taggedposts'),
                    'options'       => $options,
                    'separator'     => '<br>',
                    'defaultvalue'  => !empty($configdata['tagselect']) ? $configdata['tagselect'] : $tags[0]->tag,
                    'required'      => true,
                ),
                'count'     => array(
                    'type'          => 'text',
                    'title'         => get_string('itemstoshow', 'blocktype.taggedposts'),
                    'defaultvalue'  => isset($configdata['count']) ? $configdata['count'] : 10,
                    'size'          => 3,
                    'rules'         => array('integer' => true, 'minvalue' => 1, 'maxvalue' => 999),
                ),
            );
        }
        else {
            return array(
                'notags'    => array(
                    'type'          => 'html',
                    'title'         => get_string('taglist', 'blocktype.taggedposts'),
                    'value'         => get_string('notagsavailable', 'blocktype.taggedposts'),
                ),
            );
        }

    }

    public static function default_copy_type() {
        return 'nocopy';
    }

    /**
     * Taggedposts blocktype is only allowed in personal views, because currently
     * there's no such thing as group/site blogs
     */
    public static function allowed_in_view(View $view) {
        return $view->get('owner') != null;
    }

}