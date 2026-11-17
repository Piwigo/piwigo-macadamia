(function ($) {
  'use strict';
  function init() {
    var root = document.querySelector('.macadam-picture-container');
    if (!root) return;
    var dropdownTrigger = document.querySelector('.js-picture-dropdown-trigger');
    var dropdownMenu = document.querySelector('.album-dropdown-menu');
    var dropdownContainer = dropdownMenu && dropdownMenu.parentElement;
    var image = document.getElementById('theMainImage');
    var display = document.querySelector('.macadam-photo-display');
    var cookiePath = root.getAttribute('data-cookie-path') || '/';
    var rootUrl = root.getAttribute('data-root-url') || '';

    var openRatingForm = document.getElementById('openRatingForm');
    var interactiveRatingForm = document.getElementById('interactiveRateForm');
    var interactiveRatingValue = document.getElementById('interactiveRateValue');
    var interactiveRatingStars = interactiveRatingForm && interactiveRatingForm.querySelectorAll('.interactive-rating-star');
    var selectedRating = 0;

    function renderRating(rating) {
      if (!interactiveRatingStars) return;
      interactiveRatingStars.forEach(function (star, index) {
        var starRating = index + 1;
        var icon = star.querySelector('i');
        var className = starRating <= rating ? 'icon-star-1' : 'icon-star-empty';
        icon.className = className;
      });
    }

    if (openRatingForm && interactiveRatingForm) {
      openRatingForm.addEventListener('click', function () {
        openRatingForm.style.display = 'none';
        interactiveRatingForm.style.display = 'flex';
        selectedRating = 0;
        interactiveRatingValue.value = '';
        renderRating(selectedRating);
      });

      interactiveRatingStars.forEach(function (star) {
        star.addEventListener('mouseenter', function (event) {
          renderRating(Number(star.dataset.rating));
        });
        star.addEventListener('mouseleave', function () {
          renderRating(selectedRating);
        });
        star.addEventListener('click', function () {
          selectedRating = Number(star.dataset.rating);
          interactiveRatingValue.value = selectedRating;
          renderRating(selectedRating);
        });
      });

      interactiveRatingForm.addEventListener('mouseleave', function () {
        renderRating(selectedRating);
      });

      interactiveRatingForm.querySelector('.interactive-rating-close').addEventListener('click', function () {
        interactiveRatingForm.style.display = 'none';
        openRatingForm.style.display = '';
      });

      interactiveRatingForm.addEventListener('submit', function (event) {
        if (!selectedRating) {
          event.preventDefault();
          interactiveRatingForm.style.display = 'none';
          openRatingForm.style.display = '';
        }
      });
    }

    function hideSwitchBoxes() {
      dropdownMenu.querySelectorAll('.switchBox').forEach(function (switchBox) {
        switchBox.style.display = 'none';
      });
    }

    if (dropdownTrigger && dropdownMenu) {
      dropdownContainer.addEventListener('mouseleave', function () {
        hideSwitchBoxes();
      });

      dropdownTrigger.addEventListener('click', function (event) {
        event.preventDefault();
        event.stopPropagation();
        var isVisible = dropdownMenu.classList.toggle('show-menu');
        if (!isVisible) hideSwitchBoxes();
      });
      document.addEventListener('click', function (event) {
        if (!dropdownMenu.contains(event.target) && !dropdownTrigger.contains(event.target)) {
          dropdownMenu.classList.remove('show-menu');
          hideSwitchBoxes();
        }
      });
    }

    document.querySelectorAll('.macadam-picture-container .has-switchbox > a, .macadam-picture-container .resettable-box > a').forEach(function (link) {
      var switchBox = link.parentElement.querySelector('.switchBox');
      if (!switchBox) return;
      link.addEventListener('click', function (event) {
        event.preventDefault();
        event.stopPropagation();
        var isVisible = switchBox.style.display === 'block';
        hideSwitchBoxes();
        switchBox.style.display = isVisible ? 'none' : 'block';
      });
    });

    document.querySelectorAll('.macadam-derivative-link').forEach(function (link) {
      link.addEventListener('click', function (event) {
        event.preventDefault();
        if (!image) return;
        image.removeAttribute('width');
        image.removeAttribute('height');
        image.src = link.dataset.url;
        image.classList.add('macadam-natural-size');
        image.useMap = '#map' + link.dataset.type;
        document.cookie = 'picture_deriv=' + link.dataset.save + ';path=' + cookiePath;
        document.cookie = 'macadam_auto_derivative=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=' + cookiePath;
        document.querySelectorAll('#derivativeSwitchBox .switchCheck').forEach(function (item) {
          item.style.visibility = 'hidden';
        });
        var checked = document.getElementById('derivativeChecked' + link.dataset.type);
        if (checked) checked.style.visibility = 'visible';
      });
    });

    var derivatives = Array.from(document.querySelectorAll('.macadam-derivative-link')).map(function (link) {
      return { type: link.dataset.type, url: link.dataset.url, width: Number(link.dataset.width), height: Number(link.dataset.height) };
    });
    if (image && display && derivatives.length &&
        document.cookie.indexOf('picture_deriv=') === -1 &&
        document.cookie.indexOf('macadam_auto_derivative=1') === -1) {
      var availableWidth = display.clientWidth;
      var availableHeight = window.innerHeight * 0.8;
      var smallest = derivatives.reduce(function (a, b) { return a.width < b.width ? a : b; });
      var selected = derivatives.filter(function (item) {
        return item.width <= availableWidth && item.height <= availableHeight;
      }).sort(function (a, b) { return b.width - a.width; })[0] || smallest;
      image.removeAttribute('width');
      image.removeAttribute('height');
      image.src = selected.url;
      image.useMap = '#map' + selected.type;
      document.cookie = 'picture_deriv=' + selected.type + ';path=' + cookiePath;
      document.cookie = 'macadam_auto_derivative=1;path=' + cookiePath;
    }

    var caddie = document.querySelector('.js-add-to-caddie');
    if (caddie) caddie.addEventListener('click', function (event) {
      event.preventDefault();
      if (caddie.disabled || typeof window.PwgWS !== 'function') return;
      caddie.disabled = true;
      new window.PwgWS(rootUrl).callService('pwg.caddie.add', { image_id: caddie.dataset.imageId }, {
        onFailure: function (number, text) { window.alert(number + ' ' + text); window.location = caddie.href; },
        onSuccess: function () { caddie.disabled = false; }
      });
    });
  }
  document.addEventListener('DOMContentLoaded', init);
}(window.jQuery));
