(function () {
  'use strict';
  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.toc-album-item.has-sub-albums .album-toggle').forEach(function (toggle) {
      toggle.addEventListener('click', function (event) {
        event.stopPropagation();
        toggle.closest('.toc-album-item').classList.toggle('expanded');
      });
    });
  });
}());
