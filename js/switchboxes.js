(function () {
  'use strict';
  window.SwitchBox = window.SwitchBox || [];
  [
    ['#derivativeSwitchLink', '#derivativeSwitchBox'],
    ['#sortOrderLink', '#sortOrderBox'],
    ['#downloadSwitchLink', '#downloadSwitchBox']
  ].forEach(function (pair) {
    if (document.querySelector(pair[0]) && document.querySelector(pair[1])) {
      window.SwitchBox.push(pair[0], pair[1]);
    }
  });
}());
