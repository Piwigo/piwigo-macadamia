<?php

global $conf;

load_language('theme.lang', PHPWG_THEMES_PATH . 'macadam/');

$config_send = array();

if (isset($_POST['submit_macadam'])) {
  $default_layout = isset($_POST['default_layout']) ? $_POST['default_layout'] : 'grid';
  if (!in_array($default_layout, array('grid', 'list'), true)) {
    $default_layout = 'grid';
  }

  $config_send['default_layout'] = $default_layout;
  $config_send['header_image_id'] = isset($_POST['header_image_id'])
    ? max(0, intval($_POST['header_image_id']))
    : 0;
  $header_height_mode = isset($_POST['header_height_mode']) ? $_POST['header_height_mode'] : 'pixels';
  if (!in_array($header_height_mode, array('pixels', 'fullscreen'), true)) {
    $header_height_mode = 'pixels';
  }
  $header_height = isset($_POST['header_height']) ? intval($_POST['header_height']) : 250;
  $header_height = min(2000, max(100, $header_height));
  $config_send['header_height_mode'] = $header_height_mode;
  $config_send['header_height'] = $header_height;
  $thumbnail_metadata_fields = array('format', 'filesize', 'date_creation', 'author', 'date_available');
  $thumbnail_metadata = isset($_POST['thumbnail_metadata']) && is_array($_POST['thumbnail_metadata'])
    ? array_values(array_intersect($thumbnail_metadata_fields, $_POST['thumbnail_metadata']))
    : array();
  $config_send['thumbnail_metadata'] = $thumbnail_metadata;
  conf_update_param('macadam', $config_send, true);
  array_push($page['infos'], l10n('Information data registered in database'));
}

$options = isset($conf['macadam']) ? safe_unserialize($conf['macadam']) : array();
if (!is_array($options)) {
  $options = array();
}
if (!isset($options['default_layout']) || !in_array($options['default_layout'], array('grid', 'list'), true)) {
  $options['default_layout'] = 'grid';
}
$options['header_image_id'] = isset($options['header_image_id']) ? intval($options['header_image_id']) : 0;
$options['header_height_mode'] = isset($options['header_height_mode'])
  && in_array($options['header_height_mode'], array('pixels', 'fullscreen'), true)
  ? $options['header_height_mode']
  : 'pixels';
$options['header_height'] = isset($options['header_height'])
  ? min(2000, max(100, intval($options['header_height'])))
  : 250;
$thumbnail_metadata_fields = array('format', 'filesize', 'date_creation', 'author', 'date_available');
$options['thumbnail_metadata'] = isset($options['thumbnail_metadata']) && is_array($options['thumbnail_metadata'])
  ? array_values(array_intersect($thumbnail_metadata_fields, $options['thumbnail_metadata']))
  : array('format', 'filesize');

$header_images = array();
$query = '
SELECT id, name, path
  FROM ' . IMAGES_TABLE . '
  ORDER BY id DESC
  LIMIT 200
;';
$result = pwg_query($query);
if ($result) {
  while ($row = pwg_db_fetch_assoc($result)) {
    $header_images[] = $row;
  }
}

$template->set_filenames(array(
  'theme_admin_content' => dirname(__FILE__) . '/admin.tpl'
));
$template->assign('options', $options);
$template->assign('header_images', $header_images);
$template->assign_var_from_handle('ADMIN_CONTENT', 'theme_admin_content');
