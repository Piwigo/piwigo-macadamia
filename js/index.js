(function () {
  'use strict';

  function init() {
    var container = document.querySelector('.macadam-albums-container');
    var photos = document.getElementById('thumbnails');
    var button = document.getElementById('toggleLayoutLink');
    var icon = button && button.querySelector('i');
    var configured = document.body.getAttribute('data-macadam-default-layout') === 'list' ? 'list' : 'grid';
    var stored = window.localStorage.getItem('macadam-preferred-layout');
    var layout = stored === 'grid' || stored === 'list' ? stored : configured;

    function applyLayout(value) {
      var isGrid = value === 'grid';
      if (icon) {
        icon.classList.toggle('icon-lines', isGrid);
        icon.classList.toggle('icon-grid', !isGrid);
      }
      if (container) {
        container.classList.toggle('view-grid', isGrid);
        container.classList.toggle('view-list', !isGrid);
      }
      if (photos) {
        photos.classList.toggle('view-grid-thumbnails', isGrid);
        photos.classList.toggle('view-list-thumbnails', !isGrid);
      }
    }

    applyLayout(layout);
    if (button) {
      button.addEventListener('click', function (event) {
        event.preventDefault();
        var next = container && container.classList.contains('view-grid') ? 'list' : 'grid';
        applyLayout(next);
        window.localStorage.setItem('macadam-preferred-layout', next);
      });
    }

    document.querySelectorAll('.macadam-album-card').forEach(function (card) {
      card.addEventListener('click', function (event) {
        if (event.target.closest('a, button, .album-actions-trigger')) return;
        var link = card.querySelector('.macadam-album-thumbs');
        if (link) window.location.href = link.href;
      });
    });

    var trigger = document.querySelector('.js-album-dropdown-trigger');
    var menu = document.querySelector('.album-dropdown-menu');
    if (trigger && menu) {
      trigger.addEventListener('click', function (event) {
        event.preventDefault();
        event.stopPropagation();
        menu.classList.toggle('show-menu');
      });
      document.addEventListener('click', function (event) {
        if (!menu.contains(event.target) && !trigger.contains(event.target)) {
          menu.classList.remove('show-menu');
        }
      });
    }
  }

  document.addEventListener('DOMContentLoaded', init);
}());
