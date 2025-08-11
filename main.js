
// Mobile nav (simple) & minor enhancements
document.addEventListener('DOMContentLoaded', () => {
  const navToggle = document.querySelector('[data-nav-toggle]');
  const menu = document.querySelector('[data-nav-menu]');
  if (navToggle && menu) {
    // Ensure aria-expanded is set for accessibility
    navToggle.setAttribute('aria-expanded', 'false');

    const closeMenu = () => {
      menu.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
    };

    const toggleMenu = () => {
      const isOpen = menu.classList.toggle('open');
      navToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    };

    navToggle.addEventListener('click', toggleMenu);

    // Close menu when a link inside is clicked
    menu.addEventListener('click', (e) => {
      if (e.target.closest('a')) {
        closeMenu();
      }
    });

    // Close menu when focus moves outside of toggle or menu
    document.addEventListener('focusin', (e) => {
      if (
        menu.classList.contains('open') &&
        !menu.contains(e.target) &&
        !navToggle.contains(e.target)
      ) {
        closeMenu();
      }
    });
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', (e) => {
      const id = a.getAttribute('href').slice(1);
      const target = document.getElementById(id);
      if(target){
        e.preventDefault();
        target.scrollIntoView({behavior:'smooth', block:'start'});
      }
    });
  });
});
