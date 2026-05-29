/*!
 * RevealComicFit
 * Reveal.js plugin: keeps each comic slide's content inside the slide bounds.
 *
 * The comic theme renders at a fixed slide size with center:false and
 * auto-stretch:false, so dense slides either crop (overflow:hidden classes) or
 * spill past the inked card. comic.lua wraps every slide's body in a single
 * scalable element (.comic-fit, reusing .comic-stage on speech/action/explosion
 * slides). This plugin measures that wrapper against the slide's available inner
 * box and sets --comic-fit-scale so the theme's `transform: scale()` shrinks the
 * content to fit. Scaling targets only the wrapper, never the <section>, so the
 * pseudo-element frames and the page-turn rotateY transform stay intact.
 *
 * Hybrid floor: content shrinks down to minScale (default 0.5). For flow slides
 * (panel/halftone/section/generic) that still overflow at the floor, the plugin
 * locks the wrapper height to its scaled height and tags the slide
 * `comic-fit-scroll` so the inner box scrolls with the comic scrollbar instead
 * of cropping. Stage slides (short by genre) clamp at the floor without scroll.
 *
 * Config (reveal config key `comicFit`, all optional):
 *   enabled   {boolean} default true
 *   minScale  {number}  default 0.5   floor below which the scroll fallback kicks in
 *   maxScale  {number}  default 1      never enlarge content
 *   tolerance {number}  default 1      px slack to avoid sub-pixel jitter
 */

var RevealComicFit = window.RevealComicFit || (function () {

  function getConfig(reveal) {
    var user = (reveal && reveal.getConfig && reveal.getConfig().comicFit) || {};
    return {
      enabled: user.enabled !== false,
      minScale: typeof user.minScale === "number" ? user.minScale : 0.5,
      maxScale: typeof user.maxScale === "number" ? user.maxScale : 1,
      tolerance: typeof user.tolerance === "number" ? user.tolerance : 1
    };
  }

  function isPrinting(reveal) {
    if (document.body && document.body.classList.contains("print-pdf")) return true;
    var root = reveal && reveal.getRevealElement && reveal.getRevealElement();
    return !!(root && root.classList.contains("print-pdf"));
  }

  function px(value) {
    var n = parseFloat(value);
    return isNaN(n) ? 0 : n;
  }

  function resetFit(section, fit) {
    fit.style.removeProperty("--comic-fit-scale");
    fit.style.height = "";
    section.classList.remove("comic-fit-scroll");
  }

  // Natural extent (including margins) of an element's laid-out children, in
  // layout pixels. Used for the flex-centred .comic-stage, where overflow grows
  // symmetrically and scrollHeight under-reports it.
  function childExtent(el) {
    var minT = Infinity, maxB = -Infinity, minL = Infinity, maxR = -Infinity;
    var found = false;
    Array.prototype.forEach.call(el.children, function (child) {
      var cs = getComputedStyle(child);
      if (cs.display === "none") return;
      found = true;
      var top = child.offsetTop - px(cs.marginTop);
      var bottom = child.offsetTop + child.offsetHeight + px(cs.marginBottom);
      var left = child.offsetLeft - px(cs.marginLeft);
      var right = child.offsetLeft + child.offsetWidth + px(cs.marginRight);
      if (top < minT) minT = top;
      if (bottom > maxB) maxB = bottom;
      if (left < minL) minL = left;
      if (right > maxR) maxR = right;
    });
    if (!found) return { w: 0, h: 0 };
    return { w: maxR - minL, h: maxB - minT };
  }

  function fitOne(reveal, section, cfg) {
    if (!section) return;
    var fit = section.querySelector(":scope > .comic-fit");
    if (!fit) return;

    // Opt-outs and print: render at natural size and let native scroll (for
    // .scrollable) or reveal.js pagination (for print) handle overflow.
    if (isPrinting(reveal) || !cfg.enabled
      || section.classList.contains("scrollable")
      || section.getAttribute("data-comic-fit") === "false") {
      resetFit(section, fit);
      return;
    }

    resetFit(section, fit);
    if (section.offsetWidth === 0 || section.offsetHeight === 0) return;
    void fit.offsetHeight;

    var isStage = fit.classList.contains("comic-stage");
    var availW, availH, contentW, contentH;

    if (isStage) {
      var fs = getComputedStyle(fit);
      availW = fit.clientWidth - px(fs.paddingLeft) - px(fs.paddingRight);
      availH = fit.clientHeight - px(fs.paddingTop) - px(fs.paddingBottom);
      var extent = childExtent(fit);
      contentW = extent.w;
      contentH = extent.h;
    } else {
      var ss = getComputedStyle(section);
      availW = section.clientWidth - px(ss.paddingLeft) - px(ss.paddingRight);
      availH = section.clientHeight - px(ss.paddingTop) - px(ss.paddingBottom);
      // Reserve room for in-flow siblings (heading chip); skip the absolute
      // caption and any decorative/hidden siblings.
      Array.prototype.forEach.call(section.children, function (child) {
        if (child === fit) return;
        var cs = getComputedStyle(child);
        if (cs.position === "absolute" || cs.position === "fixed") return;
        if (cs.display === "none") return;
        availH -= child.offsetHeight + px(cs.marginTop) + px(cs.marginBottom);
      });
      contentW = fit.scrollWidth;
      contentH = fit.scrollHeight;
    }

    if (availW <= 0 || availH <= 0 || contentW <= 0 || contentH <= 0) return;

    var tol = cfg.tolerance;
    var scale = Math.min(cfg.maxScale, (availW + tol) / contentW, (availH + tol) / contentH);
    if (scale >= 1 - 0.005) return; // fits at natural size; leave scale at 1

    if (scale < cfg.minScale) scale = cfg.minScale;
    fit.style.setProperty("--comic-fit-scale", scale.toFixed(4));

    // Flow slides: lock the wrapper height (width is left alone so text does not
    // re-wrap) so the section flow reflects the visual size.
    if (!isStage) {
      if (contentH * scale > availH + tol) {
        // Overflows at the floor: bound the wrapper to the available height so
        // it scrolls internally (CSS overflow:auto), keeping the section
        // overflow visible so the hanging chip/caption are not clipped. availH
        // already excludes the in-flow chip height (see the sibling loop above).
        fit.style.height = availH + "px";
        section.classList.add("comic-fit-scroll");
      } else {
        fit.style.height = (contentH * scale) + "px";
      }
    }
  }

  function fitAll(reveal, cfg) {
    var root = reveal.getRevealElement();
    if (!root) return;
    root.querySelectorAll("section").forEach(function (section) {
      fitOne(reveal, section, cfg);
    });
  }

  function apply(reveal, section) {
    var cfg = getConfig(reveal);
    requestAnimationFrame(function () {
      if (section) {
        fitOne(reveal, section, cfg);
      } else {
        fitAll(reveal, cfg);
      }
    });
  }

  return {
    id: "comic-fit",
    init: function (reveal) {
      reveal.on("ready", function () { apply(reveal); });
      reveal.on("slidechanged", function (e) { apply(reveal, e.currentSlide); });
      // resize fires in rapid bursts during a window drag; debounce so the
      // full-deck re-fit (with its per-slide reflows) runs once it settles.
      var resizeTimer = null;
      reveal.on("resize", function () {
        if (resizeTimer) clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
          resizeTimer = null;
          apply(reveal);
        }, 150);
      });
      // Web fonts change text metrics after first layout; re-fit once loaded.
      if (document.fonts && document.fonts.ready) {
        document.fonts.ready.then(function () { apply(reveal); });
      }
    }
  };
})();

window.RevealComicFit = RevealComicFit;
