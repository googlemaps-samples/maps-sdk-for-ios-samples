const body = document.body;
const navToggle = document.querySelector('.nav-toggle');
const siteNav = document.querySelector('.site-nav');
const navLinks = [...document.querySelectorAll('.site-nav a')];

if (navToggle && siteNav) {
  navToggle.addEventListener('click', () => {
    const expanded = navToggle.getAttribute('aria-expanded') === 'true';
    navToggle.setAttribute('aria-expanded', String(!expanded));
    siteNav.classList.toggle('is-open');
  });

  navLinks.forEach((link) => {
    link.addEventListener('click', () => {
      siteNav.classList.remove('is-open');
      navToggle.setAttribute('aria-expanded', 'false');
    });
  });
}

const revealItems = document.querySelectorAll('.reveal');
const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        revealObserver.unobserve(entry.target);
      }
    });
  },
  {
    threshold: 0.14,
    rootMargin: '0px 0px -50px 0px'
  }
);

revealItems.forEach((item) => revealObserver.observe(item));

const sections = [...document.querySelectorAll('main section[id]')];
const sectionObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      const id = entry.target.id;
      navLinks.forEach((link) => {
        const active = link.getAttribute('href') === `#${id}`;
        link.classList.toggle('is-active', active);
      });
    });
  },
  {
    threshold: 0.45,
    rootMargin: '-20% 0px -35% 0px'
  }
);

sections.forEach((section) => sectionObserver.observe(section));

const slides = [...document.querySelectorAll('.deck-slide')];
const slideNav = document.getElementById('slideNav');
const progressBar = document.getElementById('slideProgress');
const prevSlideButton = document.getElementById('prevSlide');
const nextSlideButton = document.getElementById('nextSlide');
let activeSlide = 1;

function buildSlideNav() {
  if (!slideNav) return;

  slides.forEach((slide, index) => {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.textContent = String(index + 1);
    btn.setAttribute('aria-label', `Go to slide ${index + 1}`);
    if (index === 0) btn.classList.add('is-active');
    btn.addEventListener('click', () => setActiveSlide(index + 1));
    slideNav.appendChild(btn);
  });
}

function updateProgress(index) {
  if (!progressBar) return;
  progressBar.style.width = `${(index / slides.length) * 100}%`;
}

function setActiveSlide(index) {
  if (index < 1 || index > slides.length) return;

  activeSlide = index;
  slides.forEach((slide, slideIndex) => {
    slide.classList.toggle('active', slideIndex === index - 1);
  });

  if (slideNav) {
    [...slideNav.children].forEach((btn, btnIndex) => {
      btn.classList.toggle('is-active', btnIndex === index - 1);
    });
  }

  updateProgress(index);

  if (prevSlideButton) prevSlideButton.disabled = index === 1;
  if (nextSlideButton) nextSlideButton.disabled = index === slides.length;
}

buildSlideNav();
setActiveSlide(activeSlide);

if (prevSlideButton) {
  prevSlideButton.addEventListener('click', () => setActiveSlide(activeSlide - 1));
}

if (nextSlideButton) {
  nextSlideButton.addEventListener('click', () => setActiveSlide(activeSlide + 1));
}

document.addEventListener('keydown', (event) => {
  const deckInView = document.getElementById('presentation');
  if (!deckInView) return;

  const rect = deckInView.getBoundingClientRect();
  const visible = rect.top < window.innerHeight && rect.bottom > 0;
  if (!visible) return;

  if (event.key === 'ArrowRight') {
    setActiveSlide(activeSlide + 1);
  }

  if (event.key === 'ArrowLeft') {
    setActiveSlide(activeSlide - 1);
  }
});
