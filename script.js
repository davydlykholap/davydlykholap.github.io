const lens = document.querySelector('.lens');

if (window.matchMedia('(pointer: fine)').matches) {
  window.addEventListener('pointermove', ({ clientX, clientY }) => {
    lens.style.left = `${clientX}px`;
    lens.style.top = `${clientY}px`;
    lens.classList.add('visible');
  });

  document.addEventListener('mouseleave', () => lens.classList.remove('visible'));
}
