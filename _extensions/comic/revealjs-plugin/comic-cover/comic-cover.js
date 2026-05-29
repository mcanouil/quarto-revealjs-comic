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
  function bleed(reveal, cover) {
    var background = reveal.getSlideBackground(cover);
    if (!background || background.querySelector(".cover-decor")) return;

    var decor = cover.querySelector(".cover-decor");
    if (!decor) return;

    background.classList.add("comic-cover");
    background.appendChild(decor.cloneNode(true));
    reveal.getRevealElement().classList.add("comic-cover-bled");
  }

  return {
    id: "comic-cover",
    init: function (reveal) {
      reveal.on("ready", function () {
        var root = reveal.getRevealElement();
        if (!root) return;
        var cover = root.querySelector(COVER_SELECTOR);
        if (!cover) return;

        bleed(reveal, cover);

        // Per-slide: only the cover slide reveals the bled background. The cover
        // section is a stable node, so navigation just toggles the root class
        // instead of re-querying the DOM on every slidechanged.
        function toggleOnCover() {
          root.classList.toggle("comic-on-cover", reveal.getCurrentSlide() === cover);
        }
        toggleOnCover();
        reveal.on("slidechanged", toggleOnCover);
      });
    }
  };
})();

window.RevealComicCover = RevealComicCover;
