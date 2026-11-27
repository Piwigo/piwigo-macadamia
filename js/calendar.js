(function () {
  'use strict';

  function init() {
    var selectors = document.querySelectorAll('.cal-date-selector');

    function closePopovers(except) {
      selectors.forEach(function (selector) {
        var popover = selector.querySelector('.cal-date-popover');
        var button = selector.querySelector('button');
        if (popover && popover !== except) {
          popover.hidden = true;
          button.setAttribute('aria-expanded', 'false');
        }
      });
    }

    selectors.forEach(function (selector) {
      var button = selector.querySelector('button');
      var popover = selector.querySelector('.cal-date-popover');
      button.addEventListener('click', function (event) {
        event.stopPropagation();
        var willOpen = popover.hidden;
        closePopovers(popover);
        popover.hidden = !willOpen;
        button.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
      });
      popover.addEventListener('click', function (event) {
        event.stopPropagation();
      });
    });

    document.addEventListener('click', function () {
      closePopovers();
    });
    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') {
        closePopovers();
      }
    });
  }

  document.addEventListener('DOMContentLoaded', init);
}());
