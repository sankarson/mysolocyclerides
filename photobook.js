document.addEventListener("DOMContentLoaded", () => {
    document.title = `${CONFIG.country} ${CONFIG.year}`;
    document.getElementById('header-title').textContent = `${CONFIG.country} ${CONFIG.year}`;
    document.getElementById('header-subtitle').textContent = CONFIG.dates;

    const mainWrapper = document.getElementById('main-wrapper');
    const thumbWrapper = document.getElementById('thumb-wrapper');
    const pageIndicator = document.getElementById('page-indicator');

    const getPageLabel = (index) => {
        if (index === 0) return "Cover";
        return `Page ${index * 2 - 1}-${index * 2}`;
    };

    const handleImageError = (img) => {
        img.closest('.swiper-slide').classList.add('image-missing');
    };

    // --- Build slides ---
    for (let i = 0; i < CONFIG.totalImages; i++) {
        const label = getPageLabel(i);
        const fileName = `${CONFIG.imagePrefix}${i}.jpg`;
        const isFirst = i === 0;

        // Main Slide
        const mainSlide = document.createElement('div');
        mainSlide.className = 'swiper-slide';
        mainSlide.innerHTML = `
            <div class="swiper-zoom-container">
                <img src="${fileName}" alt="${label}" class="main-image"
                    loading="${isFirst ? 'eager' : 'lazy'}"${isFirst ? ' fetchpriority="high"' : ''}>
            </div>`;
        mainSlide.querySelector('.main-image').addEventListener('error', (e) => handleImageError(e.target));
        mainWrapper.appendChild(mainSlide);

        // Thumb Slide
        const thumbSlide = document.createElement('div');
        thumbSlide.className = 'swiper-slide';
        thumbSlide.innerHTML = `
            <img src="${CONFIG.thumbnailFolder}${fileName}" alt="${label}" class="thumb-image" loading="lazy">
            <div class="thumb-label">${label}</div>
        `;
        thumbSlide.querySelector('.thumb-image').addEventListener('error', (e) => handleImageError(e.target));
        thumbWrapper.appendChild(thumbSlide);
    }

    pageIndicator.textContent = getPageLabel(0);

    // --- Initialize Swipers ---
    const thumbSwiper = new Swiper('.thumb-swiper', {
        spaceBetween: 10,
        slidesPerView: 6,
        freeMode: true,
        watchSlidesProgress: true,
        breakpoints: {
            320: { slidesPerView: 3 },
            640: { slidesPerView: 4 },
            1024: { slidesPerView: 6 }
        }
    });

    const mainSwiper = new Swiper('.main-viewer', {
        effect: 'flip',
        flipEffect: {
            slideShadows: true,
            limitRotation: true,
        },
        spaceBetween: 0,
        speed: 700,
        grabCursor: true,
        zoom: true,
        keyboard: {
            enabled: true,
        },
        thumbs: {
            swiper: thumbSwiper,
        },
        on: {
            slideChange: function () {
                pageIndicator.textContent = getPageLabel(this.activeIndex);
            }
        }
    });

    // --- Navigation ---
    document.querySelector('.prev-zone').addEventListener('click', (e) => {
        e.stopPropagation();
        mainSwiper.slidePrev();
    });
    document.querySelector('.next-zone').addEventListener('click', (e) => {
        e.stopPropagation();
        mainSwiper.slideNext();
    });

    // --- Fullscreen Toggle ---
    document.getElementById('main-viewer').addEventListener('click', () => {
        document.body.classList.toggle('is-fullscreen');
        // Force Swiper to recalculate dimensions after layout change
        setTimeout(() => {
            mainSwiper.update();
        }, 100);
    });
});
