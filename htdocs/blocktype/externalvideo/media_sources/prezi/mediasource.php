<?php

require_once(dirname(__FILE__) . '/../Media_base.php');

class Media_prezi implements MediaBase {

    private static $base_url = 'http://www.prezi.com/';

    private static $default_width  = 550;
    private static $default_height = 400;

    private static $embed_sources  = array(
        array(
            'match' => '#.*https?://(www\.)?prezi\.com/bin/preziloader\.swf\?prezi_id=([a-zA-Z0-9]+).*#',
            'url'   => 'http://prezi.com/bin/preziloader.swf?prezi_id=$2',
        ),
        array(
            'match' => '#.*?"preziEmbed_([a-zA-Z0-9]+)".*#',
            'url'   => 'http://prezi.com/bin/preziloader.swf?prezi_id=$1',
        ),
        array(
            'match' => '#.*?prezi.com/([a-zA-Z0-9]+)/.*#',
            'url'   => 'http://prezi.com/bin/preziloader.swf?prezi_id=$1',
        ),
    );

    public function process_url($input, $width=0, $height=0) {
        $width  = $width  ? (int)$width  : self::$default_width;
        $height = $height ? (int)$height : self::$default_height;

        foreach (self::$embed_sources as $source) {
            if (preg_match($source['match'], $input)) {
                $output = preg_replace($source['match'], $source['url'], $input);
                $result = array(
                    'videoid' => $output,
                    'type'    => 'embed',
                    'width'   => $width,
                    'height'  => $height,
                );
                return $result;
            }
        }
        return false;
    }

    public function validate_url($input) {
        foreach (self::$embed_sources as $source) {
            if (preg_match($source['match'], $input)) {
                return true;
            }
        }
        return false;
    }

    public function get_base_url() {
        return self::$base_url;
    }
}