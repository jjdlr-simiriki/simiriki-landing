// Navegación suave para enlaces internos
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener('click', function (e) {
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth' });
    }
  });
});

// Menú móvil
const menuToggle = document.querySelector('[data-nav-toggle]');
const navMenu = document.querySelector('[data-nav-menu]');
if (menuToggle && navMenu) {
  menuToggle.addEventListener('click', () => {
    navMenu.classList.toggle('open');
  });
}

// Contadores animados
const counters = document.querySelectorAll('.number[data-count]');
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const target = parseFloat(el.dataset.count);
        const duration = 2000;
        const startTime = performance.now();
        function update(now) {
          const progress = Math.min((now - startTime) / duration, 1);
          const value = el.dataset.count.includes('.')
            ? (target * progress).toFixed(1)
            : Math.floor(target * progress);
          el.textContent = el.dataset.count.includes('%') ? value + '%' : value;
          if (progress < 1) requestAnimationFrame(update);
        }
        requestAnimationFrame(update);
        observer.unobserve(el);
      }
    });
  },
  { threshold: 0.5 },
);

counters.forEach((el) => observer.observe(el));

// Stripe checkout button
const checkoutButton = document.getElementById('checkout-button');
if (checkoutButton) {
  checkoutButton.addEventListener('click', async () => {
    try {
      const response = await fetch('/api/create-checkout-session', {
        method: 'POST',
      });
      const data = await response.json();
      if (data.url) {
        window.location.href = data.url;
      }
    } catch (err) {
      console.error('Error initiating checkout', err);
    }
  });
}

// Simple i18n toggle (EN/ES) for key elements
(function () {
  const t = {
    en: {
      nav_solutions: 'Solutions',
      nav_security: 'Security',
      nav_pricing: 'Pricing',
      nav_contact: 'Contact',
      hero_title: 'Automation, Cybersecurity, and GenAI for LATAM SMBs',
      hero_sub:
        'Automate workflows, strengthen security, and scale with Microsoft + GenAI — designed for small and mid‑size businesses in Latin America.',
      hero_cta1: 'Book a 20-min assessment',
      hero_cta2: 'See solutions',
    },
    es: {
      nav_solutions: 'Soluciones',
      nav_security: 'Seguridad',
      nav_pricing: 'Precios',
      nav_contact: 'Contacto',
      hero_title: 'Automatización, Ciberseguridad y GenAI para PyMEs en LATAM',
      hero_sub:
        'Automatiza procesos, fortalece la seguridad y escala con Microsoft + GenAI — diseñado para pequeñas y medianas empresas en Latinoamérica.',
      hero_cta1: 'Agenda evaluación de 20 min',
      hero_cta2: 'Ver soluciones',
    },
  };
  const btn = document.getElementById('lang-toggle');
  if (!btn) return;
  let lang = 'en';
  function apply() {
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      const k = el.getAttribute('data-i18n');
      if (t[lang][k]) el.textContent = t[lang][k];
    });
    btn.textContent = lang === 'en' ? 'ES' : 'EN';
    document.documentElement.lang = lang;
  }
  btn.addEventListener('click', () => {
    lang = lang === 'en' ? 'es' : 'en';
    apply();
  });
  apply();
})();
