(function ($) {
  'use strict';
  $(function () {
    $(document).on('click', '.photo-actions-trigger', function (event) {
      event.preventDefault();
      event.stopPropagation();
      var $menu = $(this).children('.pic-dropdown-menu');
      $('.pic-dropdown-menu').not($menu).removeClass('is-active');
      $menu.toggleClass('is-active');
    });
    $(document).on('click', function () {
      $('.pic-dropdown-menu').removeClass('is-active');
    });
    $(document).on('click', '.pic-dropdown-menu .dropdown-item', function (event) {
      event.preventDefault();
      event.stopPropagation();
      var $item = $(this);
      if ($item.hasClass('btn-edit-pic') || $item.hasClass('btn-download-photos')) {
        window.location.href = $item.attr('href');
      } else if ($item.hasClass('btn-share-pic')) {
        var url = $item.closest('.macadam-photo-card').find('.macadam-photo-link').attr('href');
        if (navigator.share) {
          navigator.share({ title: document.title, url: url }).catch(function (error) {
            if (error.name !== 'AbortError') console.error('Unable to share the picture.', error);
          });
        } else if (navigator.clipboard) {
          navigator.clipboard.writeText(url).then(function () {
            window.alert('Photo link copied to the clipboard!');
          });
        }
      }
      $('.pic-dropdown-menu').removeClass('is-active');
    });
  });
}(window.jQuery));
