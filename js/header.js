(function ($) {
  'use strict';
  function init() {
    var overlay = document.querySelector('.mobile-menu-overlay');
    function closeAll() {
      document.querySelectorAll('.sidebar-dropdown-container.mobile-active').forEach(function (item) {
        item.classList.remove('mobile-active');
      });
      if (overlay) overlay.classList.remove('active');
      document.body.style.overflow = '';
    }
    if (overlay) overlay.addEventListener('click', closeAll);
    document.querySelectorAll('.sidebar-dropdown-container').forEach(function (container) {
      var menu = container.querySelector('.sidebar-dropdown-menu');
      if (menu) {
        container.addEventListener('mouseenter', function () {
          if (window.innerWidth > 768) menu.style.top = container.getBoundingClientRect().top - 21 + 'px';
        });
        var toggle = container.querySelector('.sidebar-icon-link-drop');
        if (toggle) toggle.addEventListener('click', function (event) {
          if (window.innerWidth <= 768) {
            event.preventDefault();
            if (container.classList.contains('mobile-active')) return closeAll();
            closeAll();
            container.classList.add('mobile-active');
            document.body.style.overflow = 'hidden';
          }
        });
        var close = container.querySelector('.mobile-close-btn');
        if (close) close.addEventListener('click', function (event) {
          event.preventDefault();
          event.stopPropagation();
          closeAll();
        });
      }
    });
  }
  document.addEventListener('DOMContentLoaded', init);
  $(function () {
    $('.sidebar-dropdown-menu').on('click', '.album-toggle', function (event) {
      event.preventDefault();
      event.stopPropagation();
      $(this).toggleClass('open').closest('li').children('.sub-album-list').slideToggle(250);
    });
  });
}(window.jQuery));
