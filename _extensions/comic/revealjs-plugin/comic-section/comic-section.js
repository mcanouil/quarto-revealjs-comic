/*!
 * RevealComicSection
 * Reveal.js plugin: bleeds the comic .section chapter splash over the whole
 * browser window. It stamps the comic-section class onto each .section slide's
 * full-viewport .slide-background element so the yellow starburst fills the
 * display instead of stopping at the letterboxed slide box.
 *
 * Reveal.js renders each slide's .slide-background element at full viewport size
 * (this is how data-background-color fills the whole screen). The starburst is
 * pure CSS, so unlike the comic-cover plugin no DOM needs cloning: stamping the
 * class is enough. The section keeps its own in-box copy as a fallback for
 * JS-off / print; the comic-section-bled class on the .reveal root suppresses
 * that copy once the background copy is live.
 *
 * It also stamps a stable, zero-padded chapter number onto each .section slide
 * as data-comic-number, in document order. The comic theme renders this in the
 * corner via content: attr(data-comic-number). The pure-CSS counter the theme
 * keeps as a JS-off / print fallback is unreliable under navigation because
 * reveal.js sets display:none on off-screen slides and CSS counters skip
 * display:none boxes; querySelectorAll order does not, so this number is stable.
 */

var RevealComicSection = window.RevealComicSection || (function () {

  var SECTION_SELECTOR = "section.section";

  function apply(reveal) {
    var root = reveal.getRevealElement();
    if (!root) return;

    var sections = root.querySelectorAll(SECTION_SELECTOR);
    if (!sections.length) return;

    var bled = false;
    sections.forEach(function (section, idx) {
      section.setAttribute("data-comic-number", String(idx + 1).padStart(2, "0"));
      var background = reveal.getSlideBackground(section);
      if (!background) return;
      background.classList.add("comic-section");
      bled = true;
    });

    if (bled) root.classList.add("comic-section-bled");
  }

  return {
    id: "comic-section",
    init: function (reveal) {
      reveal.on("ready", function () { apply(reveal); });
      reveal.on("slidechanged", function () { apply(reveal); });
    }
  };
})();

window.RevealComicSection = RevealComicSection;
