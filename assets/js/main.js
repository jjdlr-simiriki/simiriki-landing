
// Mobile nav (simple) & minor enhancements
document.addEventListener('DOMContentLoaded', () => {
  const navToggle = document.querySelector('[data-nav-toggle]');
  const menu = document.querySelector('[data-nav-menu]');
  if(navToggle && menu){
    navToggle.addEventListener('click', () => {
      menu.classList.toggle('open');
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
