(function () {
  'use strict';
  document.addEventListener('DOMContentLoaded', function () {
    var picker = document.querySelector('.image-picker');
    var pixels = document.getElementById('header_height_mode_pixels');
    var fullscreen = document.getElementById('header_height_mode_fullscreen');
    var input = document.getElementById('header_height');
    var search = document.getElementById('header-image-search');
    var list = document.getElementById('header-image-list');
    var selected = document.getElementById('header_image_id');
    if (!picker || !search || !list || !selected || !pixels || !fullscreen || !input) return;
    var choices = list.querySelectorAll('.image-choice');
    search.addEventListener('click', function () { picker.classList.add('open'); search.select(); });
    search.addEventListener('input', function () {
      picker.classList.add('open');
      var query = search.value.toLowerCase().trim();
      choices.forEach(function (choice) { choice.hidden = query !== '' && choice.textContent.toLowerCase().indexOf(query) === -1; });
    });
    choices.forEach(function (choice) {
      choice.addEventListener('click', function () {
        selected.value = choice.getAttribute('data-image-id');
        search.value = choice.textContent.trim();
        choices.forEach(function (item) { item.classList.toggle('selected', item === choice); });
        picker.classList.remove('open');
      });
    });
    var current = list.querySelector('[data-image-id="' + selected.value + '"]');
    if (current) search.value = current.textContent.trim();
    document.addEventListener('click', function (event) {
      if (!picker.contains(event.target)) picker.classList.remove('open');
    });
    function updateHeight() { input.disabled = !pixels.checked; }
    pixels.addEventListener('change', updateHeight);
    fullscreen.addEventListener('change', updateHeight);
    updateHeight();
  });
}());
