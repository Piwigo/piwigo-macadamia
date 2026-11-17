<?php

/*
Theme Name: macadam
Version: 0.1
Description: DAM
Theme URI: http://piwigo.org/ext/extension_view.php?eid=347
Author: Piwigo Team
Author URI: http://piwigo.org/
*/

$themeconf = array(
  'parent' => 'default',
  'name' => 'macadam',
);

load_language('theme.lang', PHPWG_THEMES_PATH . 'macadam/');
add_event_handler('loc_begin_index', 'macadam_get_header_albums');
add_event_handler('loc_begin_index', 'macadam_assign_posted_calendar_url');
add_event_handler('loc_begin_picture', 'macadam_get_header_albums');
add_event_handler('loc_begin_picture', 'macadam_load_picture_menubar');
add_event_handler('loc_end_picture', 'macadam_get_picture_thumbnails');
add_event_handler('loc_begin_page_header', 'macadam_get_header_albums');
add_event_handler('loc_begin_index', 'macadam_register_smarty_functions');
add_event_handler('loc_begin_picture', 'macadam_register_smarty_functions');
add_event_handler('loc_begin_page_header', 'macadam_register_smarty_functions');
add_event_handler('loc_end_index_thumbnails', 'macadam_get_thumbnail_details');

add_event_handler('loc_begin_index', 'macadam_toc_section_init');
add_event_handler('loc_end_index', 'macadam_toc_page');
add_event_handler('loc_begin_index', 'macadam_assign_layout');
add_event_handler('loc_begin_picture', 'macadam_assign_layout');
add_event_handler('loc_begin_page_header', 'macadam_assign_layout');

/**
 * Loads the menu on photo pages.
 */
function macadam_load_picture_menubar()
{
  include_once(PHPWG_ROOT_PATH . 'include/menubar.inc.php');
}

/**
 * Builds the date-field calendar URLs for the current index context.
 */
function macadam_assign_posted_calendar_url()
{
  global $template, $page;

  $current_field = isset($page['chronology_field'])
    ? $page['chronology_field']
    : '';
  $removed = array(
    'start',
    'flat',
    'chronology_date',
    'chronology_field',
    'chronology_style',
    'chronology_view',
  );

  foreach (array('posted', 'created') as $chronology_field) {
    $template->assign(
      'MACADAM_' . strtoupper($chronology_field) . '_CALENDAR_URL',
      duplicate_index_url(
        array(
          'chronology_field' => $chronology_field,
          'chronology_style' => 'monthly',
          'chronology_view' => 'calendar',
        ),
        $removed
      )
    );
  }

  $template->assign('MACADAM_CALENDAR_FIELD', $current_field);
  $template->assign(
    'MACADAM_POSTED_CALENDAR_URL',
    duplicate_index_url(
      array(
        'chronology_field' => $current_field === 'posted' ? 'created' : 'posted',
        'chronology_style' => 'monthly',
        'chronology_view' => 'calendar',
      ),
      $removed
    )
  );
}

/**
 * Gets the layout and header settings used by the theme.
 *
 * It runs on album pages, photo pages, and the page header. It reads the
 * saved Macadam options, chooses grid or list mode, and sends the values to
 * Smarty. If a header photo was chosen, it checks that the current user can
 * see it before using it.
 */
function macadam_assign_layout()
{
  global $conf, $template, $user;

  $options = isset($conf['macadam']) ? safe_unserialize($conf['macadam']) : array();
  $default_layout = (is_array($options) && isset($options['default_layout']))
    ? $options['default_layout']
    : 'grid';

  if (!in_array($default_layout, array('grid', 'list'), true)) {
    $default_layout = 'grid';
  }

  $template->assign('MACADAM_DEFAULT_LAYOUT', $default_layout);

  $header_image_url = '';
  $header_image_id = isset($options['header_image_id']) ? intval($options['header_image_id']) : 0;
  if ($header_image_id > 0) {
    $query = '
SELECT i.id, i.path, i.representative_ext
  FROM ' . IMAGES_TABLE . ' i
    INNER JOIN ' . IMAGE_CATEGORY_TABLE . ' ic ON ic.image_id = i.id
    INNER JOIN ' . USER_CACHE_CATEGORIES_TABLE . ' uc ON uc.cat_id = ic.category_id
  WHERE i.id = ' . $header_image_id . '
    AND uc.user_id = ' . intval($user['id']) . '
  LIMIT 1
;';
    $result = pwg_query($query);
    if ($result && $row = pwg_db_fetch_assoc($result)) {
      $header_image_url = DerivativeImage::url(IMG_LARGE, new SrcImage($row));
    }
  }

  $template->assign('MACADAM_HEADER_IMAGE_URL', $header_image_url);

  $header_height_mode = (isset($options['header_height_mode'])
    && $options['header_height_mode'] === 'fullscreen') ? 'fullscreen' : 'pixels';
  $header_height = isset($options['header_height']) ? intval($options['header_height']) : 250;
  $header_height = min(2000, max(100, $header_height));
  $template->assign('MACADAM_HEADER_HEIGHT', $header_height_mode === 'fullscreen'
    ? '100vh'
    : $header_height . 'px');
}
/**
 * Makes the Macadam helpers available in Smarty templates.
 *
 * This is hooked to a few page events because different pages can render
 * templates in different ways. The small flag stops the helpers from being
 * registered twice. It uses the newer Smarty method when available and keeps
 * the older method for older Piwigo versions.
 */
function macadam_register_smarty_functions()
{
  global $template;

  static $registered = false;
  if ($registered) {
    return;
  }

  $smarty = method_exists($template, 'get_smarty') ? $template->get_smarty() : $template->smarty;
  if (!$smarty) {
    return;
  }

  if (method_exists($smarty, 'registerPlugin')) {
    $smarty->registerPlugin('function', 'macadam_get_extra_images', 'macadam_smarty_get_extra_images');
    $smarty->registerPlugin('function', 'macadam_has_photos', 'macadam_smarty_has_photos');
  } else {
    $smarty->register_function('macadam_get_extra_images', 'macadam_smarty_get_extra_images');
    $smarty->register_function('macadam_has_photos', 'macadam_smarty_has_photos');
  }

  $registered = true;
}

/**
 * Tells a template if the current page has any photos.
 *
 * It is used as the macadam_has_photos Smarty helper. The helper checks
 * Piwigo's page items and can put the true/false result into a Smarty
 * variable when the template gives it an assign name.
 */
function macadam_smarty_has_photos($params, $smarty)
{
  global $page;
  $has_photos = !empty($page['items']);
  if (isset($params['assign'])) {
    $smarty->assign($params['assign'], $has_photos);
  }
}

/**
 * Finds a few extra photos for the related-photo section.
 *
 * A template gives it albums ID and the photos currently being shown. It
 * looks in those albums and their child albums, keeps only photos the user can
 * access, skips the current photos, and returns the two newest matches.
 */
function macadam_smarty_get_extra_images($params, $smarty)
{
  global $user;

  $cat_id = isset($params['cat_id']) ? intval($params['cat_id']) : 0;
  $main_img_id = isset($params['main_img_id']) ? intval($params['main_img_id']) : 0;

  $extra_images = array();

  if ($cat_id > 0) {
    $query = '
SELECT DISTINCT i.id, i.path, i.representative_ext, i.date_available
  FROM ' . IMAGE_CATEGORY_TABLE . ' ic
    INNER JOIN ' . IMAGES_TABLE . ' i ON i.id = ic.image_id
    INNER JOIN ' . CATEGORIES_TABLE . ' c ON c.id = ic.category_id
    INNER JOIN ' . USER_CACHE_CATEGORIES_TABLE . ' uc ON c.id = uc.cat_id AND uc.user_id = ' . $user['id'] . '
  WHERE (c.id = ' . $cat_id . '
         OR c.uppercats LIKE "' . $cat_id . ',%"
         OR c.uppercats LIKE "%,' . $cat_id . ',%"
         OR c.uppercats LIKE "%,' . $cat_id . '")
    AND i.id != ' . $main_img_id . '
  ORDER BY i.date_available DESC
  LIMIT 2
;';
    $result = pwg_query($query);
    while ($row = pwg_db_fetch_assoc($result)) {
      if (!empty($row['path']) && class_exists('SrcImage')) {
        $extra_images[] = array(
          'src_image' => new SrcImage(array(
            'id' => $row['id'],
            'path' => $row['path'],
            'representative_ext' => $row['representative_ext']
          )),
        );
      }
    }
  }

  if (isset($params['assign'])) {
    $smarty->assign($params['assign'], $extra_images);
  }
}

/**
 * Prepares the albums and other links shown in the theme header.
 *
 * It runs on album pages, photo pages, and the page header. It loads the
 * albums once, puts child albums under their parent, and sends album counts,
 * tags, favorites, and contact/share links to Smarty. The global flag is
 * there because more than one Piwigo event can call this function in one page.
 */
function macadam_get_header_albums()
{
  global $template, $user, $conf, $pwg_loaded_plugins;

  if (isset($GLOBALS['macadam_albums_loaded'])) {
    return;
  }
  $GLOBALS['macadam_albums_loaded'] = true;

  $sharealbum_links = array();
  $sharealbum_active = false;

  if (isset($pwg_loaded_plugins['ShareAlbum'])) {
    $sharealbum_active = true;

    $query_share = "SELECT cat, code FROM " . SHAREALBUM_TABLE;
    $result_share = pwg_query($query_share);
    
    if ($result_share) {
      while ($row_share = pwg_db_fetch_assoc($result_share)) {
        $sharealbum_links[$row_share['cat']] = sharealbum_get_shareable_url($row_share['code']);
      }
    }
  }

  $template->assign(array(
    'SHAREALBUM_ACTIVE' => $sharealbum_active,
    'SHAREALBUM_LINKS'  => $sharealbum_links,
  ));

  $header_contact = null;
  if (isset($pwg_loaded_plugins['ContactForm'])) {
    $header_contact = array(
      'TITLE' => l10n('Contact'),
      'NAME'  => l10n('Contact'),
      'URL'   => get_root_url() . 'index.php?/contact',
    );
  }
  $template->assign('MACADAM_HEADER_CONTACT', $header_contact);

  $display_empty = !empty($conf['display_empty_categories']);
  $empty_condition = $display_empty ? '' : ' AND uc.count_images > 0';

  $query = '
SELECT c.id, c.name, c.permalink, c.id_uppercat, c.comment, uc.count_images, uc.count_categories,
       i.id AS img_id, i.path, i.representative_ext
  FROM ' . CATEGORIES_TABLE . ' c
    INNER JOIN ' . USER_CACHE_CATEGORIES_TABLE . ' uc ON c.id = uc.cat_id AND uc.user_id = ' . $user['id'] . '
    LEFT JOIN ' . IMAGES_TABLE . ' i ON i.id = c.representative_picture_id
  WHERE c.visible = \'true\'' . $empty_condition . '
  ORDER BY c.global_rank
;';
  $result = pwg_query($query);

  $albums_by_id = array();
  while ($row = pwg_db_fetch_assoc($result)) {
    $row['URL'] = make_index_url(array('category' => $row));

    $row['NAME'] = $row['name'];
    $row['DESCRIPTION'] = $row['comment'];
    $row['nb_images'] = $row['count_images'];
    $row['id_UP'] = $row['id_uppercat'];
    $row['TN_ALT'] = htmlspecialchars($row['name']);
    $row['representative_picture_id'] = $row['img_id'];

    if (!empty($row['path']) && class_exists('SrcImage')) {
      $row['representative'] = array(
        'src_image' => new SrcImage(array(
          'id' => $row['img_id'],
          'path' => $row['path'],
          'representative_ext' => $row['representative_ext']
        )),
      );
    }

    $row['sub_albums'] = array();
    $albums_by_id[$row['id']] = $row;
  }

  $total_albums = count($albums_by_id);
  $total_images = 0;

  $header_albums = array();
  foreach ($albums_by_id as $id => &$cat) {
    if (empty($cat['id_uppercat']) || !isset($albums_by_id[$cat['id_uppercat']])) {
      $header_albums[$id] = &$cat;
      $total_images += $cat['count_images'];
    } else {
      $albums_by_id[$cat['id_uppercat']]['sub_albums'][] = &$cat;
    }
  }
  unset($cat);

  $template->assign('MACADAM_HEADER_ALBUMS', $header_albums);
  $template->assign('MACADAM_ALL_ALBUMS', $albums_by_id);
  $template->assign('MACADAM_TOTAL_ALBUMS', $total_albums);
  $template->assign('MACADAM_TOTAL_IMAGES', $total_images);

  $query_tags = 'SELECT id, name, url_name FROM ' . TAGS_TABLE . ' ORDER BY name ASC;';
  $result_tags = pwg_query($query_tags);
  $header_tags = array();
  while ($row = pwg_db_fetch_assoc($result_tags)) {
    $row['URL'] = make_index_url(array('tags' => array($row)));
    $header_tags[] = $row;
  }
  $template->assign('MACADAM_HEADER_TAGS', $header_tags);

  $query_favs = '
SELECT i.id, i.name, i.file
  FROM ' . FAVORITES_TABLE . ' uf
    INNER JOIN ' . IMAGES_TABLE . ' i ON i.id = uf.image_id
  WHERE uf.user_id = ' . $user['id'] . '
  ORDER BY i.date_available DESC
  LIMIT 10
;';
  $result_favs = pwg_query($query_favs);
  $header_favorites = array();
  while ($row = pwg_db_fetch_assoc($result_favs)) {
    $name = !empty($row['name']) ? $row['name'] : $row['file'];
    $url = make_picture_url(array('image_id' => $row['id']));
    $header_favorites[] = array('name' => $name, 'URL' => $url);
  }
  $template->assign('MACADAM_HEADER_FAVORITES', $header_favorites);
}

/**
 * Builds the small photo list shown below a picture.
 *
 * It runs at the end of a picture page and uses the image IDs already chosen
 * by Piwigo. It loads the needed data in one query, keeps the same order, and
 * makes both small and large image URLs. The picture template reads the final
 * MACADAM_THUMBS list to draw the thumbnail strip.
 */
function macadam_get_picture_thumbnails()
{
  global $template, $page;

  if (empty($page['items']) || !isset($page['category']['id'])) {
    return;
  }

  include_once(PHPWG_ROOT_PATH . 'include/functions_picture.inc.php');

  $macadam_thumbs = array();

  $query = '
SELECT id, name, file, path
  FROM ' . IMAGES_TABLE . '
  WHERE id IN (' . implode(',', $page['items']) . ')
;';
  $result = pwg_query($query);

  $images_data = array();
  while ($row = pwg_db_fetch_assoc($result)) {
    $images_data[$row['id']] = $row;
  }

  foreach ($page['items'] as $img_id) {
    if (!isset($images_data[$img_id])) {
      continue;
    }

    $img = $images_data[$img_id];
    $url = make_picture_url(array('image_id' => $img['id'], 'category' => $page['category']));

    if (class_exists('SrcImage')) {
      $src_image = new SrcImage($img);
      $derivative = new DerivativeImage(IMG_SQUARE, $src_image);
      $src_url = $derivative->get_url();
      $full_derivative = new DerivativeImage(IMG_LARGE, $src_image);
      $full_src_url = $full_derivative->get_url();
    } else {
      $src_url = preg_replace('#^./#', '', $img['path']);
      $full_src_url = $src_url;
    }

    $macadam_thumbs[] = array(
      'id' => $img['id'],
      'TITLE' => !empty($img['name']) ? $img['name'] : $img['file'],
      'URL' => $url,
      'SRC' => $src_url,
      'FULL_SRC' => $full_src_url,
    );
  }

  $template->assign('MACADAM_THUMBS', $macadam_thumbs);
}

/**
 * Adds the selected extra information below album thumbnails.
 *
 * Piwigo calls this after it has made the thumbnail list. The function reads
 * the Macadam settings, loads the file size, dates, and author in one query,
 * then adds the chosen values as MACADAM_METADATA. The album templates can
 * display that data without changing Piwigo's normal thumbnail fields.
 */
function macadam_get_thumbnail_details($tpl_thumbnails)
{
  global $conf;

  if (!is_array($tpl_thumbnails) || empty($tpl_thumbnails)) {
    return $tpl_thumbnails;
  }

  $thumbnail_metadata_fields = array('format', 'filesize', 'date_creation', 'author', 'date_available');
  $options = isset($conf['macadam']) ? safe_unserialize($conf['macadam']) : array();
  $thumbnail_metadata = is_array($options) && isset($options['thumbnail_metadata'])
    && is_array($options['thumbnail_metadata'])
    ? array_values(array_intersect($thumbnail_metadata_fields, $options['thumbnail_metadata']))
    : array('format', 'filesize');

  $image_ids = array();
  foreach ($tpl_thumbnails as $thumb) {
    if (isset($thumb['id'])) {
      $image_ids[] = $thumb['id'];
    }
  }

  if (empty($image_ids)) {
    return $tpl_thumbnails;
  }

  $query = '
SELECT id, file, filesize, date_creation, author, date_available
  FROM ' . IMAGES_TABLE . '
  WHERE id IN (' . implode(',', $image_ids) . ')
;';
  $result = pwg_query($query);
  $details = array();
  while ($row = pwg_db_fetch_assoc($result)) {
    $details[$row['id']] = $row;
  }

  foreach ($tpl_thumbnails as &$thumb) {
    if (isset($thumb['id']) && isset($details[$thumb['id']])) {
      $file = $details[$thumb['id']]['file'];
      $metadata = array();
      if (in_array('format', $thumbnail_metadata, true)) {
        $metadata['format'] = strtoupper(pathinfo($file, PATHINFO_EXTENSION));
      }

      $filesize = $details[$thumb['id']]['filesize'];
      if (in_array('filesize', $thumbnail_metadata, true) && is_numeric($filesize) && $filesize > 0) {
        $metadata['filesize'] = ($filesize > 1024) ? round($filesize / 1024, 1) . ' MB' : $filesize . ' KB';
      }
      if (in_array('date_creation', $thumbnail_metadata, true)
        && !empty($details[$thumb['id']]['date_creation'])) {
        $metadata['date_creation'] = format_date(
          $details[$thumb['id']]['date_creation'],
          array('day', 'month', 'year')
        );
      }
      if (in_array('author', $thumbnail_metadata, true)
        && !empty($details[$thumb['id']]['author'])) {
        $metadata['author'] = $details[$thumb['id']]['author'];
      }
      if (in_array('date_available', $thumbnail_metadata, true)
        && !empty($details[$thumb['id']]['date_available'])) {
        $metadata['date_available'] = format_date(
          $details[$thumb['id']]['date_available'],
          array('day', 'month', 'year')
        );
      }
      $thumb['MACADAM_METADATA'] = array_values(array_filter($metadata));
    }
  }
  unset($thumb);

  return $tpl_thumbnails;
}

/**
 * Recognizes the theme's table-of-content page.
 *
 * It runs when an index page starts and checks the requested page name. When
 * it finds table_of_content, it fills in the page values that Piwigo and the
 * theme need, including the section name, title, and body ID.
 */
function macadam_toc_section_init()
{
  global $tokens, $page;
  if (isset($tokens[0]) && $tokens[0] == 'table_of_content') {
    $page['section'] = 'table_of_content';
    $page['title'] = 'Table of content';
    $page['body_id'] = 'theTableOfContentPage';
    $page['is_external'] = true;
    $page['is_homepage'] = false;
  }
}

/**
 * Displays the table of content inside Piwigo's normal page layout.
 *
 * It only runs after macadam_toc_section_init has found the right page. It
 * makes sure the header data exists, gives the template empty category and
 * thumbnail lists, renders table_of_content.tpl, and puts the result in
 * Piwigo's CONTENT variable.
 */
function macadam_toc_page()
{
  global $template, $page;

  if (isset($page['section']) && $page['section'] == 'table_of_content') {
    if (!isset($template->get_template_vars()['MACADAM_HEADER_ALBUMS'])) {
      macadam_get_header_albums();
    }
    
    $template->assign(array(
      'CATEGORIES' => array(),
      'THUMBNAILS' => array(),
    ));

    $template->set_filename('tableofcontent', 'table_of_content.tpl');
    $template->assign_var_from_handle('CONTENT', 'tableofcontent');
  }
}
?>