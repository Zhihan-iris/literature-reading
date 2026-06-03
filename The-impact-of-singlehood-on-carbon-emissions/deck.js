(function () {
  const slides = Array.from(document.querySelectorAll(".slide"));
  const progress = document.querySelector(".progress span");
  const counter = document.querySelector(".counter");
  const first = document.querySelector("[data-action='first']");
  const prev = document.querySelector("[data-action='prev']");
  const next = document.querySelector("[data-action='next']");
  const last = document.querySelector("[data-action='last']");
  const print = document.querySelector("[data-action='print']");
  let current = 0;

  function fromHash() {
    const match = window.location.hash.match(/^#\/?(\d+)$/);
    if (!match) return 0;
    return Math.max(0, Math.min(slides.length - 1, Number(match[1]) - 1));
  }

  function show(index, updateHash) {
    current = Math.max(0, Math.min(slides.length - 1, index));
    slides.forEach((slide, i) => slide.classList.toggle("active", i === current));
    const ratio = ((current + 1) / slides.length) * 100;
    if (progress) progress.style.width = ratio + "%";
    if (counter) counter.textContent = `${current + 1} / ${slides.length}`;
    if (updateHash) {
      history.replaceState(null, "", `#/${current + 1}`);
    }
  }

  function bind(button, handler) {
    if (button) button.addEventListener("click", handler);
  }

  bind(first, () => show(0, true));
  bind(prev, () => show(current - 1, true));
  bind(next, () => show(current + 1, true));
  bind(last, () => show(slides.length - 1, true));
  bind(print, () => window.print());

  window.addEventListener("keydown", (event) => {
    if (event.key === "ArrowRight" || event.key === "PageDown" || event.key === " ") {
      event.preventDefault();
      show(current + 1, true);
    }
    if (event.key === "ArrowLeft" || event.key === "PageUp") {
      event.preventDefault();
      show(current - 1, true);
    }
    if (event.key === "Home") {
      event.preventDefault();
      show(0, true);
    }
    if (event.key === "End") {
      event.preventDefault();
      show(slides.length - 1, true);
    }
  });

  window.addEventListener("hashchange", () => show(fromHash(), false));
  show(fromHash(), false);
})();
