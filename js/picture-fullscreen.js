(function () {
  'use strict';
  var rootUrl = (document.querySelector('.macadam-picture-container') || document.body).getAttribute('data-root-url') || '';

  document.addEventListener('DOMContentLoaded', function() {

  const tabInfo = document.getElementById('tabInfoLink');
  const tabComments = document.getElementById('tabCommentsLink');
  const viewInfo = document.getElementById('macadam-sidebar-info-view');
  const viewComments = document.getElementById('macadam-sidebar-comments-view');

  if(tabInfo && tabComments) {
  tabInfo.addEventListener('click', function() {
  tabInfo.classList.add('active');
  tabComments.classList.remove('active');
  viewInfo.style.display = 'block';
  viewComments.style.display = 'none';
  });
  tabComments.addEventListener('click', function() {
  tabComments.classList.add('active');
  tabInfo.classList.remove('active');
  viewInfo.style.display = 'none';
  viewComments.style.display = 'block';
  });
  }

  const toggleBtn = document.getElementById('toggle-comment-form');
  const commentForm = document.getElementById('commentAdd');

  if (toggleBtn && commentForm) {
  toggleBtn.addEventListener('click', function(e) {
  e.preventDefault();
  if (commentForm.style.display === 'none' || commentForm.style.display === '') {
  commentForm.style.display = 'block';
  toggleBtn.style.transform = 'rotate(45deg)';
  } else {
  commentForm.style.display = 'none';
  toggleBtn.style.transform = 'rotate(0deg)';
  }
  });
  }

  const fsToggle = document.getElementById('macadam-fullscreen-toggle');
  const fsCloseBtn = document.getElementById('macadam-fullscreen-close-btn');
  const container = document.querySelector('.macadam-picture-container');
  const photoDis = document.querySelector('.macadam-photo-display');
  const theImage = document.getElementById('theImage');
  const navArrowFullscreen = document.querySelectorAll('.macadam-nav-arrow');
  const carouselStrip = document.querySelector('.macadam-carousel-strip');

  const arrowLeft = document.querySelector('.macadam-main-photo-stage .macadam-nav-arrow.arrow-left');
  const arrowRight = document.querySelector('.macadam-main-photo-stage .macadam-nav-arrow.arrow-right');
  const thumbnailItems = Array.from(document.querySelectorAll('.macadam-carousel-strip .strip-thumb-item'));
  let fullscreenImageIndex = thumbnailItems.findIndex(function(item) {
  return item.classList.contains('active');
  });
  let touchStartX = 0;
  let touchStartY = 0;
  let suppressImageClick = false;

  function logFullscreenVisit(imageId) {
  const parsedImageId = parseInt(imageId, 10);
  if (!parsedImageId || typeof jQuery !== 'function') {
  console.error('Unable to log fullscreen image visit: invalid image ID or jQuery unavailable.');
  return;
  }

  jQuery.ajax({
  type: 'POST',
  url: rootUrl + 'ws.php?format=json&method=pwg.history.log',
  data: {
  image_id: parsedImageId
  },
  dataType: 'json',
  error: function(xhr, status, error) {
  console.error('Unable to log fullscreen image visit:', status, error, xhr.responseText);
  }
  });
  }

  function updateFullscreenArrowState() {
  const atFirstImage = fullscreenImageIndex <= 0;
  const atLastImage = fullscreenImageIndex >= thumbnailItems.length - 1;

  navArrowFullscreen.forEach(function(arrow) {
  if (arrow.classList.contains('arrow-left')) {
  arrow.classList.toggle('disabled', atFirstImage);
  } else if (arrow.classList.contains('arrow-right')) {
  arrow.classList.toggle('disabled', atLastImage);
  }
  });
  }

  function changeFullscreenImage(index) {
  if (!document.fullscreenElement || !thumbnailItems.length || !theImage) return false;

  const item = thumbnailItems[index];
  const image = document.getElementById('theMainImage');
  const fullSrc = item && item.dataset.fullSrc;
  if (!item || !image || !fullSrc) return false;

  fullscreenImageIndex = index;
  image.src = fullSrc;
  image.alt = item.querySelector('img') ? item.querySelector('img').alt : image.alt;
  logFullscreenVisit(item.dataset.imageId);
  thumbnailItems.forEach(function(thumbnail) {
  thumbnail.classList.toggle('active', thumbnail === item);
  });
  updateFullscreenArrowState();
  return true;
  }

  function navigateToPrevious() {
  if (document.fullscreenElement) {
  if (fullscreenImageIndex > 0) {
  changeFullscreenImage(fullscreenImageIndex - 1);
  }
  } else if (arrowLeft) {
  arrowLeft.click();
  }
  }

  function navigateToNext() {
  if (document.fullscreenElement) {
  if (fullscreenImageIndex < thumbnailItems.length - 1) {
  changeFullscreenImage(fullscreenImageIndex + 1);
  }
  } else if (arrowRight) {
  arrowRight.click();
  }
  }

  function toggleFullscreen() {
  if (!document.fullscreenElement) {
  container.requestFullscreen()
  .catch(err => console.error("Fullscreen activation failed: " + err.message));
  } else {
  sessionStorage.removeItem('macadam_persist_fullscreen');
  document.exitFullscreen();
  }
  }

  if (fsToggle && container) {
  fsToggle.addEventListener('click', toggleFullscreen);
  }
  if (fsCloseBtn) {
  fsCloseBtn.addEventListener('click', toggleFullscreen);
  }

  if (carouselStrip) {
  thumbnailItems.forEach(function(thumbnail) {
  thumbnail.addEventListener('click', function() {
  sessionStorage.setItem('macadam_carousel_scroll_left', String(carouselStrip.scrollLeft));
  });
  });
  }

  if (theImage && container) {
    theImage.addEventListener('click', function() {
      if (suppressImageClick) {
        suppressImageClick = false;
        return;
      }
      if (window.innerWidth <= 768) {
        toggleFullscreen();
      }
    });

    theImage.addEventListener('touchstart', function(e) {
      if (!document.fullscreenElement || window.innerWidth > 768 || !e.touches.length) return;
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
    }, { passive: true });

    theImage.addEventListener('touchend', function(e) {
      if (!document.fullscreenElement || window.innerWidth > 768 || !e.changedTouches.length) return;

      const touchEndX = e.changedTouches[0].clientX;
      const touchEndY = e.changedTouches[0].clientY;
      const deltaX = touchEndX - touchStartX;
      const deltaY = touchEndY - touchStartY;

      if (Math.abs(deltaX) < 50 || Math.abs(deltaX) <= Math.abs(deltaY)) return;

      e.preventDefault();
      suppressImageClick = true;
      window.setTimeout(function() {
        suppressImageClick = false;
      }, 500);
      if (deltaX < 0) {
        navigateToNext();
      } else {
        navigateToPrevious();
      }
    }, { passive: false });
  }

  if (arrowLeft) {
  arrowLeft.addEventListener('click', function(e) {
  if (document.fullscreenElement) {
  e.preventDefault();
  navigateToPrevious();
  }
  });
  }
  if (arrowRight) {
  arrowRight.addEventListener('click', function(e) {
  if (document.fullscreenElement) {
  e.preventDefault();
  navigateToNext();
  }
  });
  }

  document.addEventListener('keydown', function(e) {
  if (document.fullscreenElement && container.classList.contains('macadam-in-fullscreen')) {
  if (e.key === 'ArrowLeft') {
  e.preventDefault();
  navigateToPrevious();
  } else if (e.key === 'ArrowRight') {
  e.preventDefault();
  navigateToNext();
  } else if (e.key === 'Escape') {
  e.preventDefault();
  toggleFullscreen();
  }
  }
  });

  document.addEventListener('fullscreenchange', function() {
  if (document.fullscreenElement) {
  container.classList.add('macadam-in-fullscreen');
  photoDis.classList.add('display-in-fullscreen');
  navArrowFullscreen.forEach(arrow => arrow.classList.add('arrow-fullscreen'));
  updateFullscreenArrowState();
  } else {
  container.classList.remove('macadam-in-fullscreen');
  photoDis.classList.remove('display-in-fullscreen');
  navArrowFullscreen.forEach(arrow => arrow.classList.remove('arrow-fullscreen'));
  }
  });

  function reenterFullscreen() {
  if (sessionStorage.getItem('macadam_persist_fullscreen') === 'true' && container) {
  container.requestFullscreen()
  .then(() => {
  sessionStorage.removeItem('macadam_persist_fullscreen');
  })
  .catch(err => console.log("Reactivation is waiting for user interaction:", err.message));

  document.removeEventListener('click', reenterFullscreen);
  document.removeEventListener('keydown', reenterFullscreen);
  }
  }

  if (sessionStorage.getItem('macadam_persist_fullscreen') === 'true') {
  document.addEventListener('click', reenterFullscreen);
  document.addEventListener('keydown', reenterFullscreen);
  reenterFullscreen();
  }

  if (carouselStrip) {
  const savedCarouselScrollLeft = sessionStorage.getItem('macadam_carousel_scroll_left');
  if (savedCarouselScrollLeft !== null) {
  carouselStrip.scrollLeft = parseInt(savedCarouselScrollLeft, 10) || 0;
  sessionStorage.removeItem('macadam_carousel_scroll_left');
  }
  }

  });
  

}());
