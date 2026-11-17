(function ($) {
  'use strict';
  $(function () {
    $(document).on('click', '.album-sub-toggle', function (event) {
      event.preventDefault();
      event.stopPropagation();
      var $wrapper = $(this).closest('.album-wrapper');
      $(this).toggleClass('open');
      $wrapper.children('.sub-albums-container').slideToggle(250);
    });
    $(document).on('click', '.album-actions-trigger', function (event) {
      event.stopPropagation();
      var $menu = $(this).children('.album-dropdown-menu');
      $('.album-dropdown-menu').not($menu).removeClass('is-active');
      $menu.toggleClass('is-active');
    });
    $(document).on('click', function () {
      $('.album-dropdown-menu').removeClass('is-active');
    });
    $(document).on('click', '.album-dropdown-menu .dropdown-item', function (event) {
      var $item = $(this);
      if ($item.hasClass('btn-add-photos') || $item.hasClass('btn-edit-album')) {
        event.stopPropagation();
        $('.album-dropdown-menu').removeClass('is-active');
        return;
      }
      event.preventDefault();
      event.stopPropagation();
      if ($item.hasClass('btn-share-album')) {
        var url = $item.data('share-url');
        if ($item.data('has-link') && url) {
          navigator.clipboard.writeText(url).then(function () {
            window.alert('Share link copied to the clipboard!');
          });
        } else {
          window.location.href = 'admin.php?page=plugin-ShareAlbum-albums';
        }
      }
      $('.album-dropdown-menu').removeClass('is-active');
    });
  });
}(window.jQuery));
