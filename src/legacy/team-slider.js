class TeamSlider {
  constructor({ target }) {
    this.target = target;
    this.slider = target.querySelector('.js-team-slider');
    this.init();
  }

  init() {
    if (!this.slider) return;
    this.swiper = new Swiper(this.slider, {
      direction: 'horizontal',
      slidesPerView: 'auto',
      spaceBetween: 20,
      navigation: {
        prevEl: this.target.querySelector('.js-button-prev'),
        nextEl: this.target.querySelector('.js-button-next'),
      },
      breakpoints: {
        0: {
          spaceBetween: 6,
        },
        767: {
          spaceBetween: 20,
        }
      }
    });

    window.addEventListener('filter', e => {
      this.swiper.update();
    });
  }

  update() {
    this.swiper.update();
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const target = document.querySelector('.js-team-section');
  if (!target) return;
  new TeamSlider({ target });
});