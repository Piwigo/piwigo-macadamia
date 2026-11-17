(function () {
  'use strict';
  var loader = document.querySelector('.loader');
  if (loader && loader.dataset.errorIcon) window.error_icon = loader.dataset.errorIcon;
  if (typeof window.max_requests === 'undefined') window.max_requests = 3;
}());
