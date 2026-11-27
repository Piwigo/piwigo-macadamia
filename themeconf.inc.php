<?php

/*
Theme Name: macadamia
Version: 0.1
Description: DAM
Theme URI: http://piwigo.org/ext/extension_view.php?eid=347
Author: Piwigo Team
Author URI: http://piwigo.org/
*/

$themeconf = array(
  'parent' => 'default',
  'name' => 'macadamia',
);

load_language('theme.lang', PHPWG_THEMES_PATH . 'macadamia/');
add_event_handler('loc_begin_index', 'macadam_get_header_albums');
add_event_handler('loc_begin_index', 'macadam_assign_posted_calendar_url');
add_event_handler('loc_begin_index', 'macadam_redirect_calendar_to_latest_month');
add_event_handler('loc_begin_index', 'macadam_assign_calendar_thumbnails');
add_event_handler('loc_begin_index', 'macadam_assign_month_calendar_padding');
add_event_handler('loc_begin_index', 'macadam_assign_calendar_year_grids');
add_event_handler('loc_begin_index', 'macadam_assign_calendar_available_dates');
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
add_event_handler('ws_add_methods', 'macadam_ws_add_methods');

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
  $existing_chronology_date = isset($page['chronology_date'])
    ? $page['chronology_date']
    : array();
  $query_string = isset($_SERVER['QUERY_STRING'])
    ? rawurldecode($_SERVER['QUERY_STRING'])
    : '';
  $requested_year_only = preg_match(
    '~/(?:posted|created)-monthly-calendar-(\d{4})(?:&|$)~',
    $query_string,
    $year_match
  );

  $calendar_year = $requested_year_only
    ? intval($year_match[1])
    : (!empty($existing_chronology_date)
    ? intval($existing_chronology_date[0])
    : intval(date('Y')));
  $calendar_month = count($existing_chronology_date) >= 2
    ? intval($existing_chronology_date[1])
    : intval(date('n'));

  global $lang;
  $calendar_month_name = (
    isset($lang['month'][$calendar_month])
    ? $lang['month'][$calendar_month]
    : date('F', mktime(0, 0, 0, $calendar_month, 1, $calendar_year))
  );
  $template->assign('MACADAM_CALENDAR_MONTH', $calendar_month_name);
  $template->assign('MACADAM_CALENDAR_YEAR', (string)$calendar_year);
  $template->assign(
    'MACADAM_CALENDAR_YEAR_SELECTED',
    $requested_year_only || !empty($existing_chronology_date)
  );

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

  $existing_chronology_date = isset($page['chronology_date'])
    ? $page['chronology_date']
    : array();
  $has_selected_month = count($existing_chronology_date) >= 2
    && !$requested_year_only;
  $annual_year = $requested_year_only
    ? intval($year_match[1])
    : (!empty($existing_chronology_date)
    ? intval($existing_chronology_date[0])
    : intval(date('Y')));
  $template->assign(
    'MACADAM_ANNUAL_CALENDAR_URL',
    duplicate_index_url(
      array(
        'chronology_field' => $current_field ?: 'posted',
        'chronology_style' => 'monthly',
        'chronology_view' => 'calendar',
        'chronology_date' => array($annual_year),
      ),
      array('start', 'flat')
    )
  );

  $chronology_date = $existing_chronology_date;
  if (count($chronology_date) < 2) {
    $chronology_date = array(
      intval(date('Y')),
      intval(date('n')),
    );
  } else {
    $chronology_date = array(
      intval($chronology_date[0]),
      intval($chronology_date[1]),
    );
  }

  $template->assign(
    'MACADAM_MONTHLY_CALENDAR_URL',
    duplicate_index_url(
      array(
        'chronology_field' => $current_field ?: 'posted',
        'chronology_style' => 'monthly',
        'chronology_view' => 'calendar',
        'chronology_date' => $chronology_date,
      ),
      array('start', 'flat')
    )
  );

  $template->assign(
    'MACADAM_CALENDAR_ANNUAL_ACTIVE',
    !$has_selected_month
  );
  $template->assign(
    'MACADAM_CALENDAR_MONTHLY_ACTIVE',
    $has_selected_month
  );
}

/**
 * Assigns photo availability for the selected year and for available years.
 *
 * month: all 12 months of the selected year, true when at least one photo exists.
 * year: years between the oldest and newest matching photos, with availability.
 * The availability date follows the active chronology field (posted or created).
 */
function macadam_assign_calendar_available_dates()
{
  global $template, $page, $user, $lang;

  if (
    !isset($page['chronology_view'])
    || $page['chronology_view'] !== 'calendar'
    || !isset($page['chronology_style'])
    || $page['chronology_style'] !== 'monthly'
  ) {
    return;
  }

  $chronology_field = isset($page['chronology_field'])
    ? $page['chronology_field']
    : 'posted';
  $date_field = $chronology_field === 'posted'
    ? 'date_available'
    : 'date_creation';

  $selected_year = isset($page['chronology_date'][0])
    ? intval($page['chronology_date'][0])
    : intval(date('Y'));
  $selected_month = isset($page['chronology_date'][1])
    ? intval($page['chronology_date'][1])
    : intval(date('n'));

  $month = array();
  for ($month_number = 1; $month_number <= 12; $month_number++) {
    $month[$month_number] = false;
  }

  $query = '
SELECT DISTINCT
  ' . pwg_db_get_year($date_field) . ' AS period_year,
  ' . pwg_db_get_month($date_field) . ' AS period_month
FROM ' . IMAGES_TABLE . ' i';

  if (isset($page['section']) && $page['section'] === 'categories') {
    $query .= '
INNER JOIN ' . IMAGE_CATEGORY_TABLE . ' ic ON i.id = ic.image_id';

    if (isset($page['category'])) {
      $sub_ids = array_diff(
        get_subcat_ids(array($page['category']['id'])),
        explode(',', $user['forbidden_categories'])
      );
      if (empty($sub_ids)) {
        $query = null;
      } else {
        $query .= '
WHERE ic.category_id IN (' . implode(',', array_map('intval', $sub_ids)) . ')
  ' . get_sql_condition_FandF(
    array('visible_images' => 'i.id'),
    'AND',
    false
  );
      }
    } else {
      $query .= '
  ' . get_sql_condition_FandF(
    array(
      'forbidden_categories' => 'ic.category_id',
      'visible_categories' => 'ic.category_id',
      'visible_images' => 'i.id',
    ),
    'WHERE',
    true
  );
    }
  } elseif (!empty($page['items'])) {
    $query .= '
WHERE i.id IN (' . implode(',', array_map('intval', $page['items'])) . ')';
  } else {
    $query = null;
  }

  $available_years = array();
  $minimum_year = null;
  $maximum_year = null;
  if ($query !== null) {
    $query .= '
  AND i.' . $date_field . ' IS NOT NULL';

    $result = pwg_query($query);
    while ($row = pwg_db_fetch_assoc($result)) {
      $period_year = intval($row['period_year']);
      $period_month = intval($row['period_month']);
      if ($period_year < 1 || $period_month < 1 || $period_month > 12) {
        continue;
      }

      $available_years[$period_year] = true;
      if ($period_year === $selected_year) {
        $month[$period_month] = true;
      }
      if ($minimum_year === null || $period_year < $minimum_year) {
        $minimum_year = $period_year;
      }
      if ($maximum_year === null || $period_year > $maximum_year) {
        $maximum_year = $period_year;
      }
    }
  }

  $year = array();
  if ($minimum_year !== null && $maximum_year !== null) {
    for ($period_year = $minimum_year; $period_year <= $maximum_year; $period_year++) {
      $year[$period_year] = isset($available_years[$period_year]);
    }
  }

  $months = array();
  for ($month_number = 1; $month_number <= 12; $month_number++) {
    $months[] = array(
      'label' => isset($lang['month'][$month_number])
        ? $lang['month'][$month_number]
        : date('F', mktime(0, 0, 0, $month_number, 1, $selected_year)),
      'available' => !empty($month[$month_number]),
      'selected' => $month_number === $selected_month,
      'url' => duplicate_index_url(
        array(
          'chronology_field' => $chronology_field,
          'chronology_style' => 'monthly',
          'chronology_view' => 'calendar',
          'chronology_date' => array($selected_year, $month_number),
        ),
        array('start', 'flat')
      ),
    );
  }

  if (!isset($year[$selected_year])) {
    $year[$selected_year] = false;
  }
  ksort($year, SORT_NUMERIC);

  $year_options = array();
  $previous_year_url = null;
  $previous_year = null;
  $next_year_url = null;
  $next_year = null;
  foreach ($year as $year_number => $available) {
    $year_url = duplicate_index_url(
      array(
        'chronology_field' => $chronology_field,
        'chronology_style' => 'monthly',
        'chronology_view' => 'calendar',
        'chronology_date' => array(intval($year_number)),
      ),
      array('start', 'flat')
    );
    $year_options[] = array(
      'label' => (string)$year_number,
      'available' => $available,
      'selected' => intval($year_number) === $selected_year,
      'url' => $year_url,
    );

    if ($available && $year_number < $selected_year) {
      $previous_year_url = $year_url;
      $previous_year = $year_number;
    } elseif (
      $available
      && $year_number > $selected_year
      && $next_year_url === null
    ) {
      $next_year_url = $year_url;
      $next_year = $year_number;
    }
  }

  $template->assign('MACADAM_CALENDAR_MONTH_OPTIONS', $months);
  $template->assign('MACADAM_CALENDAR_YEAR_OPTIONS', $year_options);
  if ($previous_year_url !== null) {
    $template->assign('MACADAM_CALENDAR_PREVIOUS_YEAR_URL', $previous_year_url);
    $template->assign('MACADAM_CALENDAR_PREVIOUS_YEAR', (string)$previous_year);
  }
  if ($next_year_url !== null) {
    $template->assign('MACADAM_CALENDAR_NEXT_YEAR_URL', $next_year_url);
    $template->assign('MACADAM_CALENDAR_NEXT_YEAR', (string)$next_year);
  }
}

/**
 * Builds a Monday-to-Sunday day-count grid for a month.
 *
 * Missing days inside the month have a count of 0; padding days have a count of -1.
 */
function macadam_build_calendar_month_weeks($year, $month, $items)
{
  $days_in_month = intval(date('t', mktime(12, 0, 0, $month, 1, $year)));
  $first_weekday = intval(date('N', mktime(12, 0, 0, $month, 1, $year)));
  $day_items = array();

  foreach ($items as $item) {
    if (!isset($item['LABEL']) || !is_numeric($item['LABEL'])) {
      continue;
    }

    $day_number = intval($item['LABEL']);
    if ($day_number < 1 || $day_number > $days_in_month) {
      continue;
    }

    $day_items[$day_number] = array(
      'NB_IMAGES' => isset($item['NB_IMAGES'])
        ? intval($item['NB_IMAGES'])
        : 0,
    );
    if (isset($item['URL'])) {
      $day_items[$day_number]['URL'] = $item['URL'];
    }
  }

  $weeks = array();
  $week = array();
  $previous_month_days = intval(date('t', mktime(12, 0, 0, $month, 0, $year)));
  for ($padding = $first_weekday - 1; $padding > 0; $padding--) {
    $week[] = array(
      'DAY' => $previous_month_days - $padding + 1,
      'NB_IMAGES' => -1,
    );
  }

  for ($day_number = 1; $day_number <= $days_in_month; $day_number++) {
    $day = array(
      'DAY' => $day_number,
      'NB_IMAGES' => isset($day_items[$day_number])
        ? $day_items[$day_number]['NB_IMAGES']
        : 0,
    );
    if (isset($day_items[$day_number]['URL'])) {
      $day['URL'] = $day_items[$day_number]['URL'];
    }
    $week[] = $day;

    if (count($week) === 7) {
      $weeks[] = $week;
      $week = array();
    }
  }

  if (!empty($week)) {
    $next_month_day = 1;
    while (count($week) < 7) {
      $week[] = array(
        'DAY' => $next_month_day,
        'NB_IMAGES' => -1,
      );
      $next_month_day++;
    }
    $weeks[] = $week;
  }

  return $weeks;
}

/**
 * Builds all twelve monthly grids for a selected annual calendar.
 */
function macadam_assign_calendar_year_grids()
{
  global $template, $page, $lang;

  $smarty = method_exists($template, 'get_smarty')
    ? $template->get_smarty()
    : $template->smarty;
  if (!$smarty) {
    return;
  }

  if (
    !$smarty->getTemplateVars('MACADAM_CALENDAR_YEAR_SELECTED')
    || !$smarty->getTemplateVars('MACADAM_CALENDAR_ANNUAL_ACTIVE')
  ) {
    return;
  }

  $year = intval($smarty->getTemplateVars('MACADAM_CALENDAR_YEAR'));
  if ($year < 1) {
    return;
  }
  $chronology_field = isset($page['chronology_field'])
    ? $page['chronology_field']
    : 'posted';

  $chronology_calendar = $smarty->getTemplateVars('chronology_calendar');
  if (!is_array($chronology_calendar)) {
    $chronology_calendar = array();
  }

  $month_bars = array();
  if (!empty($chronology_calendar['calendar_bars'])) {
    foreach ($chronology_calendar['calendar_bars'] as $bar) {
      if (
        !isset($bar['U_HEAD'])
        || !preg_match(
          '~-(\d{4})-(\d{1,2})(?:-|&|$)~',
          $bar['U_HEAD'],
          $matches
        )
        || intval($matches[1]) !== $year
      ) {
        continue;
      }

      $month = intval($matches[2]);
      if ($month >= 1 && $month <= 12) {
        $month_bars[$month] = $bar;
      }
    }
  }

  if (
    empty($month_bars)
    && isset($chronology_calendar['month_view'])
    && isset($page['chronology_date'][1])
    && !empty($chronology_calendar['month_view']['weeks'])
  ) {
    $month = intval($page['chronology_date'][1]);
    if ($month >= 1 && $month <= 12) {
      $items = array();
      $month_count = 0;
      foreach ($chronology_calendar['month_view']['weeks'] as $week) {
        foreach ($week as $day) {
          if (
            empty($day)
            || isset($day['OUTSIDE_MONTH'])
            || empty($day['NB_ELEMENTS'])
          ) {
            continue;
          }

          $day_count = intval($day['NB_ELEMENTS']);
          $month_count += $day_count;
          $item = array(
            'LABEL' => intval($day['DAY']),
            'NB_IMAGES' => $day_count,
          );
          if (isset($day['U_IMG_LINK'])) {
            $item['URL'] = $day['U_IMG_LINK'];
          }
          $items[] = $item;
        }
      }

      $month_bars[$month] = array(
        'U_HEAD' => duplicate_index_url(
          array(
            'chronology_field' => $chronology_field,
            'chronology_style' => 'monthly',
            'chronology_view' => 'calendar',
            'chronology_date' => array($year, $month),
          ),
          array('start', 'flat')
        ),
        'NB_IMAGES' => $month_count,
        'HEAD_LABEL' => $lang['month'][$month],
        'items' => $items,
      );
    }
  }

  $calendar_bars = array();
  for ($month = 1; $month <= 12; $month++) {
    if (isset($month_bars[$month])) {
      $bar = $month_bars[$month];
    } else {
      $bar = array(
        'NB_IMAGES' => 0,
        'HEAD_LABEL' => $lang['month'][$month],
        'items' => array(),
      );
    }

    $bar['HEAD_LABEL'] = $lang['month'][$month];
    if (empty($bar['NB_IMAGES'])) {
      $bar['NB_IMAGES'] = 0;
    }
    $bar['calendar_weeks'] = macadam_build_calendar_month_weeks(
      $year,
      $month,
      isset($bar['items']) && is_array($bar['items'])
        ? $bar['items']
        : array()
    );
    $calendar_bars[] = $bar;
  }

  $weekday_labels = array(
    $lang['day'][1],
    $lang['day'][2],
    $lang['day'][3],
    $lang['day'][4],
    $lang['day'][5],
    $lang['day'][6],
    $lang['day'][0],
  );
  $chronology_calendar['calendar_bars'] = $calendar_bars;
  $template->assign('MACADAM_CALENDAR_WEEKDAYS', $weekday_labels);
  $template->assign('MACADAM_CALENDAR_HAS_MONTH_GRIDS', true);
  $template->assign('chronology_calendar', $chronology_calendar);
}

/**
 * Loads up to three photos for each day of the selected month.
 *
 * Piwigo's native month calendar provides one random thumbnail per day.
 * This theme helper adds a small, per-day preview stack without replacing
 * Piwigo's calendar grouping or pagination.
 */
function macadam_assign_calendar_thumbnails()
{
  global $template, $page, $user;

  // This helper is useful only on Piwigo's monthly calendar view.
  // It must have both a year and a month in chronology_date.
  if (
    !isset($page['chronology_field'])
    || !isset($page['chronology_style'])
    || !isset($page['chronology_view'])
    || $page['chronology_style'] !== 'monthly'
    || $page['chronology_view'] !== 'calendar'
    || !isset($page['chronology_date'])
    || count($page['chronology_date']) < 2
  ) {
    return;
  }

  // The calendar grid has already been built by Piwigo at this point.
  // Reuse its month_view structure.
  $smarty = method_exists($template, 'get_smarty')
    ? $template->get_smarty()
    : $template->smarty;
  if (!$smarty) {
    return;
  }

  $chronology_calendar = $smarty->getTemplateVars('chronology_calendar');
  if (!is_array($chronology_calendar) || !isset($chronology_calendar['month_view'])) {
    return;
  }

  $year = intval($page['chronology_date'][0]);
  $month = intval($page['chronology_date'][1]);

  // posted uses date_available (publication/import date);
  // created uses date_creation (the photo's EXIF or creation date).
  $date_field = $page['chronology_field'] === 'posted'
    ? 'date_available'
    : 'date_creation';

  // The SQL retrieves image data and the day number in a single query.
  // It intentionally returns all matching photos in the month: filtering
  // to three thumbnails happens below, once per day.
  $query = 'SELECT i.id, i.file, i.representative_ext, i.path, i.width, i.height, i.rotation,
    ' . pwg_db_get_dayofmonth($date_field) . ' AS day_number
FROM ' . IMAGES_TABLE . ' i';

  // Limit category views to the current album and its sub-albums.
  // USER_CACHE_CATEGORIES also applies Piwigo's visibility rules.
  if ($page['section'] === 'categories') {
    $query .= '
INNER JOIN ' . IMAGE_CATEGORY_TABLE . ' ic ON i.id = ic.image_id
INNER JOIN ' . USER_CACHE_CATEGORIES_TABLE . ' uc
  ON uc.cat_id = ic.category_id
  AND uc.user_id = ' . intval($user['id']);

    if (isset($page['category'])) {
      $sub_ids = array_diff(
        get_subcat_ids(array($page['category']['id'])),
        explode(',', $user['forbidden_categories'])
      );
      if (empty($sub_ids)) {
        return;
      }
      $query .= '
WHERE ic.category_id IN (' . implode(',', array_map('intval', $sub_ids)) . ')';
    } else {
      $query .= '
WHERE 1=1';
    }
  } elseif (!empty($page['items'])) {
    $query .= '
WHERE i.id IN (' . implode(',', array_map('intval', $page['items'])) . ')';
  } else {
    return;
  }

  // Restrict the query to the selected year/month and selected date field.
  // Escape the generated boundaries, even though they are numeric here.
  $query .= '
  AND i.' . $date_field . ' BETWEEN "' . pwg_db_real_escape_string(sprintf('%04d-%02d-01', $year, $month))
    . '" AND "' . pwg_db_real_escape_string(sprintf('%04d-%02d-%02d 23:59:59',
      $year,
      $month,
      intval(date('t', mktime(0, 0, 0, $month, 1, $year)))
    )) . '"
  AND i.' . $date_field . ' IS NOT NULL
ORDER BY i.' . $date_field . ' DESC';

  // Keep at most three derivatives for each day. This makes the loop cheap:
  // result rows beyond the third thumbnail for a day are discarded.
  $thumbnails = array();
  $result = pwg_query($query);
  while ($row = pwg_db_fetch_assoc($result)) {
    $day = intval($row['day_number']);
    if (!isset($thumbnails[$day])) {
      $thumbnails[$day] = array();
    }
    if (count($thumbnails[$day]) >= 3) {
      continue;
    }

    // Build Piwigo's square derivative URL from the native image metadata.
    // This is only a URL/derivative object, not an extra image SQL query.
    $src_image = new SrcImage(array(
      'id' => intval($row['id']),
      'path' => $row['path'],
      'representative_ext' => $row['representative_ext'],
    ));
    $derivative = new DerivativeImage(IMG_SQUARE, $src_image);
    $picture_params = array('image_id' => intval($row['id']));
    if (isset($page['category'])) {
      $picture_params['category'] = $page['category'];
    }
    $thumbnails[$day][] = array(
      'URL' => $derivative->get_url(),
      'PICTURE_URL' => make_picture_url($picture_params),
      'ALT' => $row['file'],
    );
  }

  // Attach the prepared stack to Piwigo's existing week/day structure.
  // Days outside the selected month keep their existing empty state.
  foreach ($chronology_calendar['month_view']['weeks'] as &$week) {
    foreach ($week as &$day) {
      if (empty($day) || isset($day['OUTSIDE_MONTH'])) {
        continue;
      }
      $day_number = intval($day['DAY']);
      if (!empty($thumbnails[$day_number])) {
        $day['THUMBNAILS'] = $thumbnails[$day_number];
      }
    }
  }
  unset($week, $day);

  $template->assign('chronology_calendar', $chronology_calendar);
}

/**
 * Adds adjacent-month day numbers to the empty cells in Piwigo's month grid.
 */
function macadam_assign_month_calendar_padding()
{
  global $template, $page;

  if (
    !isset($page['chronology_style'])
    || $page['chronology_style'] !== 'monthly'
    || !isset($page['chronology_view'])
    || $page['chronology_view'] !== 'calendar'
    || !isset($page['chronology_date'])
    || count($page['chronology_date']) < 2
  ) {
    return;
  }

  $smarty = method_exists($template, 'get_smarty')
    ? $template->get_smarty()
    : $template->smarty;
  if (!$smarty) {
    return;
  }

  $chronology_calendar = $smarty->getTemplateVars('chronology_calendar');
  if (
    !is_array($chronology_calendar)
    || empty($chronology_calendar['month_view']['weeks'])
  ) {
    return;
  }

  $year = intval($page['chronology_date'][0]);
  $month = intval($page['chronology_date'][1]);
  if ($year < 1 || $month < 1 || $month > 12) {
    return;
  }

  $weeks = &$chronology_calendar['month_view']['weeks'];
  $leading_cells = 0;
  while (
    isset($weeks[0][$leading_cells])
    && empty($weeks[0][$leading_cells])
  ) {
    $leading_cells++;
  }

  if ($leading_cells > 0) {
    $previous_month_days = intval(date('t', mktime(12, 0, 0, $month, 0, $year)));
    for ($column = 0; $column < $leading_cells; $column++) {
      $weeks[0][$column] = array(
        'DAY' => $previous_month_days - $leading_cells + $column + 1,
        'OUTSIDE_MONTH' => true,
      );
    }
  }

  $last_week_index = count($weeks) - 1;
  $last_day_index = count($weeks[$last_week_index]) - 1;
  while (
    $last_day_index >= 0
    && empty($weeks[$last_week_index][$last_day_index])
  ) {
    $last_day_index--;
  }

  $next_month_day = 1;
  for (
    $column = $last_day_index + 1;
    $column < count($weeks[$last_week_index]);
    $column++
  ) {
    $weeks[$last_week_index][$column] = array(
      'DAY' => $next_month_day,
      'OUTSIDE_MONTH' => true,
    );
    $next_month_day++;
  }
  unset($weeks);

  $template->assign('chronology_calendar', $chronology_calendar);
}

/**
 * Opens calendar root URLs directly on the last not empty year and month.
 */
function macadam_redirect_calendar_to_latest_month()
{
  global $page, $template;

  // Handle only the two unselected monthly-calendar root URLs.
  $query_string = isset($_SERVER['QUERY_STRING'])
    ? rawurldecode($_SERVER['QUERY_STRING'])
    : '';
  if (!preg_match(
    '~/(posted|created)-monthly-calendar$~',
    $query_string
  )) {
    return;
  }

  // Piwigo has already grouped the accessible photos by year and month so we reuse it
  $smarty = method_exists($template, 'get_smarty')
    ? $template->get_smarty()
    : $template->smarty;
  if (!$smarty) {
    return;
  }

  $chronology_calendar = $smarty->getTemplateVars('chronology_calendar');
  if (!is_array($chronology_calendar) || empty($chronology_calendar['calendar_bars'])) {
    return;
  }

  $latest_year = 0;
  $latest_month = 0;

  // calendar_bars can contain year links in U_HEAD and month links in items. compare both forms to find the latest visible period.
  foreach ($chronology_calendar['calendar_bars'] as $bar) {
    if (isset($bar['U_HEAD']) &&
        preg_match('~-(\d{4})(?:-(\d{1,2}))?(?:-|$)~', $bar['U_HEAD'], $matches)) {
      $year = intval($matches[1]);
      $month = isset($matches[2]) ? intval($matches[2]) : 0;
      if ($year > $latest_year || ($year === $latest_year && $month > $latest_month)) {
        $latest_year = $year;
        $latest_month = $month;
      }
    }

    if (!empty($bar['items']) && is_array($bar['items'])) {
      foreach ($bar['items'] as $item) {
        if (!isset($item['URL'])) {
          continue;
        }
        if (preg_match('~-(\d{4})(?:-(\d{1,2}))?(?:-|$)~', $item['URL'], $matches)) {
          $year = intval($matches[1]);
          $month = isset($matches[2]) ? intval($matches[2]) : 0;
          if ($year > $latest_year || ($year === $latest_year && $month > $latest_month)) {
            $latest_year = $year;
            $latest_month = $month;
          }
        }
      }
    }
  }

  if ($latest_year < 1) {
    return;
  }

  // fallback
  $latest_date = array($latest_year);
  if ($latest_month > 0) {
    $latest_date[] = $latest_month;
  }

  // Replace the root calendar URL with the latest existing period.
  redirect(
    duplicate_index_url(
      array('chronology_date' => $latest_date),
      array('start')
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

  $color_scheme = (is_array($options) && isset($options['color_scheme']))
    ? $options['color_scheme']
    : 'blue';
  if (!in_array($color_scheme, array('blue', 'green', 'orange', 'pink', 'bluenight', 'grayscale'), true)) {
    $color_scheme = 'blue';
  }
  $template->assign('MACADAM_COLOR_SCHEME', $color_scheme);

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
    $smarty->registerPlugin('function', 'macadam_square_derivative', 'macadam_smarty_square_derivative');
  } else {
    $smarty->register_function('macadam_get_extra_images', 'macadam_smarty_get_extra_images');
    $smarty->register_function('macadam_has_photos', 'macadam_smarty_has_photos');
    $smarty->register_function('macadam_square_derivative', 'macadam_smarty_square_derivative');
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

function macadam_smarty_square_derivative($params, $smarty)
{
  $smarty->assign($params['assign'], new DerivativeImage(IMG_SQUARE, $params['src_image']));
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

  if (empty($page['items'])) {
    return;
  }

  include_once(PHPWG_ROOT_PATH . 'include/functions_picture.inc.php');

  $ordered_items = array_values(array_filter(
    array_map('intval', $page['items']),
    function ($id) { return $id > 0; }
  ));
  $current_index = array_search(intval($page['image_id']), $ordered_items, true);
  if ($current_index === false) {
    $current_index = 0;
  }

  $window_start = max(0, $current_index - 25);
  $window_end = min(count($ordered_items), $current_index + 26);
  $window_items = array_slice($ordered_items, $window_start, $window_end - $window_start);
  $macadam_thumbs = array();

  $query = '
SELECT id, name, file, path
  FROM ' . IMAGES_TABLE . '
  WHERE id IN (' . implode(',', $window_items) . ')
;';
  $result = pwg_query($query);

  $images_data = array();
  while ($row = pwg_db_fetch_assoc($result)) {
    $images_data[$row['id']] = $row;
  }

  foreach ($window_items as $img_id) {
    if (!isset($images_data[$img_id])) {
      continue;
    }

    $img = $images_data[$img_id];
    $picture_params = array('image_id' => $img['id']);
    if (isset($page['category'])) {
      $picture_params['category'] = $page['category'];
    } elseif (isset($page['search'])) {
      $picture_params['search'] = $page['search'];
    } elseif (isset($page['tags'])) {
      $picture_params['tags'] = $page['tags'];
    } elseif (isset($page['list'])) {
      $picture_params['list'] = $page['list'];
    }
    $url = make_picture_url($picture_params);

    if (class_exists('SrcImage')) {
      $src_image = new SrcImage($img);
      $derivative = new DerivativeImage(IMG_THUMB, $src_image);
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

  $template->assign(array(
    'MACADAM_THUMBS' => $macadam_thumbs,
    'MACADAM_ITEM_IDS' => json_encode($ordered_items),
    'MACADAM_CATEGORY_ID' => isset($page['category']['id']) ? intval($page['category']['id']) : 0,
    'MACADAM_SEARCH_ID' => isset($page['search']) ? strval($page['search']) : '',
    'MACADAM_WINDOW_START' => $window_start,
    'MACADAM_WINDOW_END' => $window_end - 1,
  ));
}

/**
 * Register the small API used to lazily expand the picture carousel.
 */
function macadam_ws_add_methods($arr)
{
  $service = &$arr[0];

  $service->addMethod(
    'macadamia.images.getWindow',
    'macadam_ws_get_image_window',
    array(
      'ids' => array(),
      'offset' => array('type' => WS_TYPE_INT, 'default' => 0),
      'limit' => array('type' => WS_TYPE_INT, 'default' => 25),
      'category_id' => array('type' => WS_TYPE_ID, 'default' => null),
      'search_id' => array('default' => null),
    ),
    'get a window of images for the Macadamia carousel.'
  );
}

/**
 * Returns thumbnail/full-size URLs for a requested image window.
 */
function macadam_ws_get_image_window($params, $service)
{
  global $page;

  $ids = array_values(array_filter(array_map(
    'intval',
    explode(',', $params['ids'])
  ), function ($id) { return $id > 0; }));
  $offset = max(0, intval($params['offset']));
  $limit = min(25, max(1, intval($params['limit'])));
  $window_ids = array_slice($ids, $offset, $limit);

  if (empty($window_ids)) {
    return array();
  }

  $query = '
SELECT id, name, file, path
  FROM ' . IMAGES_TABLE . '
  WHERE id IN (' . implode(',', $window_ids) . ')
;';
  $result = pwg_query($query);
  $images_data = array();
  while ($row = pwg_db_fetch_assoc($result)) {
    $images_data[$row['id']] = $row;
  }

  $items = array();
  foreach ($window_ids as $img_id) {
    if (!isset($images_data[$img_id])) {
      continue;
    }

    $img = $images_data[$img_id];
    $url_params = array('image_id' => $img['id']);
    if (!empty($params['category_id'])) {
      $category_result = pwg_query('
SELECT id, name, permalink
  FROM ' . CATEGORIES_TABLE . '
  WHERE id = ' . intval($params['category_id']) . '
LIMIT 1
;');
      if ($category_row = pwg_db_fetch_assoc($category_result)) {
        $url_params['category'] = $category_row;
      }
    } elseif (!empty($params['search_id'])) {
      $url_params['search'] = strval($params['search_id']);
    }

    $src_image = new SrcImage($img);
    $src_url = (new DerivativeImage(IMG_THUMB, $src_image))->get_url();
    $full_src_url = (new DerivativeImage(IMG_LARGE, $src_image))->get_url();

    $items[] = array(
      'id' => intval($img['id']),
      'title' => !empty($img['name']) ? $img['name'] : $img['file'],
      'url' => make_picture_url($url_params),
      'src' => $src_url,
      'full_src' => $full_src_url,
    );
  }

  return $items;
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