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
  let thumbnailItems = Array.from(document.querySelectorAll('.macadam-carousel-strip .strip-thumb-item'));
  let fullscreenImageIndex = thumbnailItems.findIndex(function(item) {
  return item.classList.contains('active');
  });
  let touchStartX = 0;
  let touchStartY = 0;
  let suppressImageClick = false;
  const carouselContainer = document.querySelector('.carousel-strip-container');
  const allItemIds = carouselContainer
  ? JSON.parse(carouselContainer.dataset.macadamItemIds || '[]')
  : [];
  let renderedStartIndex = carouselContainer
  ? parseInt(carouselContainer.dataset.macadamWindowStart, 10)
  : 0;
  let renderedEndIndex = carouselContainer
  ? parseInt(carouselContainer.dataset.macadamWindowEnd, 10)
  : -1;
  let windowLoading = false;

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

  function createThumbnailItem(item) {
    const link = document.createElement('a');
    link.className = 'strip-thumb-item';
    link.href = item.url;
    link.dataset.fullSrc = item.full_src;
    link.dataset.imageId = String(item.id);

    const image = document.createElement('img');
    image.src = item.src;
    image.alt = item.title || '';
    link.appendChild(image);

    link.addEventListener('click', function() {
      sessionStorage.setItem('macadam_carousel_scroll_left', String(carouselStrip.scrollLeft));
    });
    return link;
  }

  function trimThumbnailWindow(direction) {
    if (thumbnailItems.length <= 101) return;

    if (direction === 'previous') {
      for (let i = 0; i < 25; i++) {
        const item = thumbnailItems[thumbnailItems.length - 1];
        if (item) {
          item.remove();
          thumbnailItems.pop();
        }
      }
      renderedEndIndex -= 25;
    } else {
      for (let i = 0; i < 25; i++) {
        const item = thumbnailItems[0];
        if (item) {
          item.remove();
          thumbnailItems.shift();
        }
      }
      fullscreenImageIndex -= 25;
      renderedStartIndex += 25;
    }
  }

  function loadThumbnailWindow(direction, onLoaded) {
    if (!carouselStrip || windowLoading || typeof jQuery !== 'function') return;

    const requestOffset = direction === 'previous'
      ? Math.max(0, renderedStartIndex - 25)
      : renderedEndIndex + 1;
    if (direction === 'previous' && renderedStartIndex <= 0) return;
    if (direction === 'next' && requestOffset >= allItemIds.length) return;

    const requestData = {
      ids: allItemIds.join(','),
      offset: requestOffset,
      limit: 25
    };
    const categoryId = parseInt(carouselContainer.dataset.macadamCategoryId, 10);
    if (categoryId > 0) {
      requestData.category_id = categoryId;
    } else {
      const searchId = carouselContainer.dataset.macadamSearchId;
      if (searchId) {
        requestData.search_id = searchId;
      }
    }

    windowLoading = true;
    jQuery.ajax({
      type: 'POST',
      url: rootUrl + 'ws.php?format=json&method=macadamia.images.getWindow',
      data: requestData,
      dataType: 'json',
      success: function(response) {
        const items = response && response.result ? response.result : [];
        if (!items.length) return;

        if (direction === 'previous') {
          const previousScrollWidth = carouselStrip.scrollWidth;
          const fragment = document.createDocumentFragment();
          items.forEach(function(item) {
            fragment.appendChild(createThumbnailItem(item));
          });
          carouselStrip.insertBefore(fragment, carouselStrip.firstChild);
          window.requestAnimationFrame(function() {
            carouselStrip.scrollLeft += carouselStrip.scrollWidth - previousScrollWidth;
          });
          fullscreenImageIndex += items.length;
          renderedStartIndex = requestOffset;
        } else {
          const previousScrollLeft = carouselStrip.scrollLeft;
          items.forEach(function(item) {
            carouselStrip.appendChild(createThumbnailItem(item));
          });
          renderedEndIndex = requestOffset + items.length - 1;
          window.requestAnimationFrame(function() {
            carouselStrip.scrollLeft = previousScrollLeft;
          });
        }

        thumbnailItems = Array.from(carouselStrip.querySelectorAll('.strip-thumb-item'));
        trimThumbnailWindow(direction);
        updateFullscreenArrowState();
        if (typeof onLoaded === 'function') {
          onLoaded();
        }
      },
      error: function(xhr, status, error) {
        console.error('Unable to load carousel thumbnails:', status, error, xhr.responseText);
      },
      complete: function() {
        windowLoading = false;
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
  if (fullscreenImageIndex <= 2 && renderedStartIndex > 0) {
  loadThumbnailWindow('previous', function() {
    navigateToPrevious();
  });
  return;
  }
  if (fullscreenImageIndex > 0) {
  changeFullscreenImage(fullscreenImageIndex - 1);
  }
  } else if (arrowLeft) {
  arrowLeft.click();
  }
  }

  function navigateToNext() {
  if (document.fullscreenElement) {
  if (fullscreenImageIndex >= thumbnailItems.length - 3 && renderedEndIndex < allItemIds.length - 1) {
    loadThumbnailWindow('next', function() {
      navigateToNext();
    });
    return;
  }
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

  let carouselScrollPending = false;
  carouselStrip.addEventListener('scroll', function() {
    if (carouselScrollPending) return;
    carouselScrollPending = true;
    window.requestAnimationFrame(function() {
      carouselScrollPending = false;
      const distanceToRight = carouselStrip.scrollWidth - carouselStrip.clientWidth - carouselStrip.scrollLeft;
      if (distanceToRight < 300) {
        loadThumbnailWindow('next');
      } else if (carouselStrip.scrollLeft < 300) {
        loadThumbnailWindow('previous');
      }
    });
  }, { passive: true });
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
  const target = e.target || e.srcElement;
  if (e.altKey || e.metaKey || (target && (target.type || target.isContentEditable))) return;

  const isFullscreen = document.fullscreenElement && container.classList.contains('macadam-in-fullscreen');
  const key = e.key || ({ 37: 'ArrowLeft', 39: 'ArrowRight', 27: 'Escape' })[e.keyCode];
  if (key === 'ArrowLeft' && (isFullscreen || e.ctrlKey || document.documentElement.scrollLeft === 0)) {
  if (isFullscreen || (arrowLeft && !arrowLeft.classList.contains('disabled'))) {
  e.preventDefault();
  navigateToPrevious();
  }
  } else if (key === 'ArrowRight' &&
    (isFullscreen || e.ctrlKey || document.documentElement.scrollLeft === document.documentElement.scrollWidth - document.documentElement.clientWidth)) {
  if (isFullscreen || (arrowRight && !arrowRight.classList.contains('disabled'))) {
  e.preventDefault();
  navigateToNext();
  }
  } else if (key === 'Escape' && isFullscreen) {
  e.preventDefault();
  toggleFullscreen();
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
