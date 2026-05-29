/*!
 * RevealComicCover
 * Reveal.js plugin: promotes the comic title-slide cover to the full-viewport
 * background layer so the whole cover (halftone paper plus every decorative
 * layer) bleeds edge-to-edge across the browser window instead of stopping at
 * the letterboxed slide box.
 *
 * Reveal.js renders each slide's .slide-background element at full viewport
 * size (this is how data-background-color fills the whole screen). The plugin
 * stamps the comic-cover host class onto the title slide's background element
 * and clones the section's purely decorative .cover-decor into it. The section
 * keeps its own copy as a fallback for JS-off / print; the comic-cover-bled
 * class on the .reveal root hides that copy once the background copy is live.
 */

var RevealComicCover = window.RevealComicCover || (function () {

  var COVER_SELECTOR = "section.title-slide.comic-cover";

  // One-time: bleed the cover decor onto the full-viewport background layer.
  function bleed(reveal) {
    var root = reveal.getRevealElement();
    if (!root) return;
    var slide = root.querySelector(COVER_SELECTOR);
    if (!slide) return;

    var background = reveal.getSlideBackground(slide);
    if (!background || background.querySelector(".cover-decor")) return;

    var decor = slide.querySelector(".cover-decor");
    if (!decor) return;

    background.classList.add("comic-cover");
    background.appendChild(decor.cloneNode(true));
    root.classList.add("comic-cover-bled");
  }

  // Per-slide: only the cover slide reveals the bled background.
  function toggleOnCover(reveal) {
    var root = reveal.getRevealElement();
    if (!root) return;
    var slide = root.querySelector(COVER_SELECTOR);
    if (!slide) return;
    root.classList.toggle("comic-on-cover", reveal.getCurrentSlide() === slide);
  }

  return {
    id: "comic-cover",
    init: function (reveal) {
      reveal.on("ready", function () { bleed(reveal); toggleOnCover(reveal); });
      reveal.on("slidechanged", function () { toggleOnCover(reveal); });
    }
  };
})();

window.RevealComicCover = RevealComicCover;
