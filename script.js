const hero = document.querySelector(".hero");
const graphic = document.querySelector(".database-graphic");
const bubbleElements = [...document.querySelectorAll(".hero-bubble")];
const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

if (hero && !prefersReducedMotion.matches) {
  const pointer = {
    active: false,
    x: 0,
    y: 0,
  };

  const bubbles = bubbleElements.map((element, index) => ({
    element,
    x: 0,
    y: 0,
    vx: [0.16, -0.13, 0.11][index] || 0.12,
    vy: [0.11, -0.09, 0.14][index] || -0.1,
    radius: 0,
  }));

  const resetBubbles = () => {
    bubbles.forEach((bubble) => {
      const heroBounds = hero.getBoundingClientRect();
      const bubbleBounds = bubble.element.getBoundingClientRect();

      bubble.radius = Math.max(bubbleBounds.width, bubbleBounds.height) / 2;
      bubble.x = bubble.element.offsetLeft;
      bubble.y = bubble.element.offsetTop;

      bubble.x = Math.min(Math.max(bubble.x, 0), heroBounds.width - bubbleBounds.width);
      bubble.y = Math.min(Math.max(bubble.y, 0), heroBounds.height - bubbleBounds.height);
    });
  };

  const animateBubbles = () => {
    const heroBounds = hero.getBoundingClientRect();

    bubbles.forEach((bubble) => {
      const size = bubble.radius * 2;

      bubble.x += bubble.vx;
      bubble.y += bubble.vy;

      if (pointer.active) {
        const centerX = bubble.x + bubble.radius;
        const centerY = bubble.y + bubble.radius;
        const dx = centerX - pointer.x;
        const dy = centerY - pointer.y;
        const distance = Math.hypot(dx, dy);
        const influence = bubble.radius + 230;

        if (distance < influence && distance > 0.01) {
          const force = (1 - distance / influence) * 0.18;
          bubble.vx += (dx / distance) * force;
          bubble.vy += (dy / distance) * force;
        }
      }

      if (bubble.x < 0 || bubble.x > heroBounds.width - size) {
        bubble.vx *= -0.48;
        bubble.x = Math.min(Math.max(bubble.x, 0), heroBounds.width - size);
      }

      if (bubble.y < 0 || bubble.y > heroBounds.height - size) {
        bubble.vy *= -0.48;
        bubble.y = Math.min(Math.max(bubble.y, 0), heroBounds.height - size);
      }

      bubble.vx *= 0.982;
      bubble.vy *= 0.982;

      if (Math.abs(bubble.vx) < 0.045) {
        bubble.vx += bubble.vx < 0 ? -0.006 : 0.006;
      }

      if (Math.abs(bubble.vy) < 0.035) {
        bubble.vy += bubble.vy < 0 ? -0.005 : 0.005;
      }

      bubble.element.style.transform = `translate3d(${bubble.x - bubble.element.offsetLeft}px, ${bubble.y - bubble.element.offsetTop}px, 0)`;
    });

    requestAnimationFrame(animateBubbles);
  };

  hero.addEventListener("pointermove", (event) => {
    const bounds = hero.getBoundingClientRect();
    const x = event.clientX - bounds.left;
    const y = event.clientY - bounds.top;
    const percentX = (x / bounds.width) * 100;
    const percentY = (y / bounds.height) * 100;

    pointer.active = true;
    pointer.x = x;
    pointer.y = y;

    hero.style.setProperty("--hero-x", `${percentX}%`);
    hero.style.setProperty("--hero-y", `${percentY}%`);

    if (graphic) {
      const tiltY = (percentX - 50) * 0.04;
      const tiltX = (percentY - 50) * -0.03;

      graphic.style.setProperty("--tilt-x", `${tiltX}deg`);
      graphic.style.setProperty("--tilt-y", `${tiltY}deg`);
    }
  });

  hero.addEventListener("pointerleave", () => {
    pointer.active = false;
    hero.style.removeProperty("--hero-x");
    hero.style.removeProperty("--hero-y");

    if (graphic) {
      graphic.style.removeProperty("--tilt-x");
      graphic.style.removeProperty("--tilt-y");
    }
  });

  window.addEventListener("resize", resetBubbles);

  resetBubbles();
  requestAnimationFrame(animateBubbles);
}
