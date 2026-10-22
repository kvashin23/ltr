document.addEventListener('DOMContentLoaded', function () {
	if (!window.Swiper) {
		return;
	}

	document.querySelectorAll('.services-slider').forEach(function (section) {
		new Swiper(section.querySelector('.services-slider__list'), {
			slidesPerView: 1.15,
			spaceBetween: 18,
			navigation: {
				nextEl: section.querySelector('.services-slider__next'),
				prevEl: section.querySelector('.services-slider__prev'),
			},
			breakpoints: {
				600: { slidesPerView: 2 },
				992: { slidesPerView: 3 },
				1280: { slidesPerView: 4 },
			},
		});
	});
});
