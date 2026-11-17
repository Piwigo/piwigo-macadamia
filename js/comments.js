(function () {
  'use strict';
  document.addEventListener('click', function (event) {
    var link = event.target.closest('.comment-delete-link');
    if (link && !window.confirm(link.getAttribute('data-confirm'))) event.preventDefault();
  });
}());
