(function () {
  'use strict';
  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.macadam-pagination-select').forEach(function (select) {
      select.addEventListener('change', function () {
        if (this.value) window.location.href = this.value;
      });
    });
  });
}());
