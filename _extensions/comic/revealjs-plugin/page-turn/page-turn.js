/*!
 * RevealComicPageTurn
 * Reveal.js plugin: synthesises a quiet page-flip whoosh on each slide
 * change so the comic theme's page-turn transition has an audio cue.
 *
 * No binary assets. The sound is generated via the Web Audio API as a
 * short band-pass filtered pink-noise burst with a fast attack and a
 * decay envelope, panned by navigation direction.
 *
 * Respects:
 *   - <section data-no-sound>        per-slide opt-out (title slide ships
 *                                    with this so the cover stays silent)
 *   - <body data-comic-sound="false"> deck-wide opt-out
 *   - prefers-reduced-motion        OS accessibility opt-out
 *
 * Public API on window.ComicPageTurn:
 *   .setMuted(boolean)
 *   .isMuted() => boolean
 *   .play(direction)  // direction: "next" | "prev"
 */

var RevealComicPageTurn = window.RevealComicPageTurn || (function () {

  var audioCtx = null;
  var muted = false;
  var lastIndexH = 0;
  var lastIndexV = 0;

  function deckOptedOut() {
    var body = document.body;
    return body && body.getAttribute("data-comic-sound") === "false";
  }

  function prefersReducedMotion() {
    return window.matchMedia
      && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  }

  function overviewActive() {
    return typeof Reveal.isOverview === "function" && Reveal.isOverview();
  }

  function ensureContext() {
    if (audioCtx) return audioCtx;
    var Ctx = window.AudioContext || window.webkitAudioContext;
    if (!Ctx) return null;
    audioCtx = new Ctx();
    return audioCtx;
  }

  function buildPinkNoiseBuffer(ctx, duration) {
    var sampleRate = ctx.sampleRate;
    var frameCount = Math.floor(sampleRate * duration);
    var buffer = ctx.createBuffer(1, frameCount, sampleRate);
    var data = buffer.getChannelData(0);
    var last = 0;
    for (var i = 0; i < frameCount; i++) {
      var white = Math.random() * 2 - 1;
      last = 0.86 * last + 0.14 * white;
      data[i] = last;
    }
    return buffer;
  }

  // An AudioBuffer is reusable across single-use source nodes, and only a fixed
  // set of durations is ever requested, so build each once and cache it.
  var noiseBuffers = {};
  function pinkNoiseBuffer(ctx, duration) {
    if (!noiseBuffers[duration]) {
      noiseBuffers[duration] = buildPinkNoiseBuffer(ctx, duration);
    }
    return noiseBuffers[duration];
  }

  function scheduleBurst(ctx, opts) {
    var source = ctx.createBufferSource();
    source.buffer = pinkNoiseBuffer(ctx, opts.duration);

    var bandpass = ctx.createBiquadFilter();
    bandpass.type = "bandpass";
    bandpass.frequency.value = opts.centre;
    bandpass.Q.value = opts.q != null ? opts.q : 0.7;

    var highpass = ctx.createBiquadFilter();
    highpass.type = "highpass";
    highpass.frequency.value = 280;

    var gain = ctx.createGain();
    var start = ctx.currentTime + opts.delay;
    var attack = opts.attack != null ? opts.attack : 0.05;
    var peak = opts.peak != null ? opts.peak : 0.16;
    var release = opts.release != null ? opts.release : 0.32;
    var end = start + opts.duration;

    gain.gain.setValueAtTime(0, start);
    gain.gain.linearRampToValueAtTime(peak, start + attack);
    gain.gain.setValueAtTime(peak, Math.max(start + attack, end - release));
    gain.gain.exponentialRampToValueAtTime(0.0001, end);

    var panner = null;
    if (typeof ctx.createStereoPanner === "function") {
      panner = ctx.createStereoPanner();
      panner.pan.value = opts.pan != null ? opts.pan : 0;
    }

    source.connect(bandpass);
    bandpass.connect(highpass);
    highpass.connect(gain);
    if (panner) {
      gain.connect(panner);
      panner.connect(ctx.destination);
    } else {
      gain.connect(ctx.destination);
    }

    source.start(start);
    source.stop(end + 0.01);
  }

  function playFlip(direction) {
    if (muted) return;
    if (deckOptedOut()) return;
    if (prefersReducedMotion()) return;
    if (overviewActive()) return;

    var ctx = ensureContext();
    if (!ctx) return;
    if (ctx.state === "suspended" && typeof ctx.resume === "function") {
      ctx.resume();
    }

    var basePan = direction === "prev" ? -0.4 : 0.4;

    // Three overlapping rustle layers across ~700 ms simulate a real
    // page turning: a low body rustle, a brighter swoosh sweeping across
    // the listener, then a soft trailing fizz as the page settles.
    scheduleBurst(ctx, {
      delay: 0,
      duration: 0.50,
      centre: 850,
      q: 0.6,
      attack: 0.08,
      release: 0.34,
      peak: 0.18,
      pan: -basePan * 0.6
    });

    scheduleBurst(ctx, {
      delay: 0.14,
      duration: 0.55,
      centre: 1800,
      q: 0.9,
      attack: 0.06,
      release: 0.42,
      peak: 0.14,
      pan: basePan
    });

    scheduleBurst(ctx, {
      delay: 0.32,
      duration: 0.40,
      centre: 3200,
      q: 1.1,
      attack: 0.05,
      release: 0.30,
      peak: 0.07,
      pan: basePan * 1.1
    });
  }

  function onSlideChanged(event) {
    if (!event) return;
    var section = event.currentSlide;
    if (section && section.hasAttribute("data-no-sound")) {
      lastIndexH = event.indexh != null ? event.indexh : lastIndexH;
      lastIndexV = event.indexv != null ? event.indexv : lastIndexV;
      return;
    }
    var direction = "next";
    if (event.indexh != null) {
      if (event.indexh < lastIndexH) direction = "prev";
      else if (event.indexh === lastIndexH && event.indexv != null && event.indexv < lastIndexV) {
        direction = "prev";
      }
      lastIndexH = event.indexh;
      lastIndexV = event.indexv != null ? event.indexv : 0;
    }
    playFlip(direction);
  }

  function onReady(event) {
    if (event && event.indexh != null) {
      lastIndexH = event.indexh;
      lastIndexV = event.indexv != null ? event.indexv : 0;
    }
    Reveal.addEventListener("slidechanged", onSlideChanged);
  }

  Reveal.addEventListener("ready", onReady);

  window.ComicPageTurn = {
    setMuted: function (value) { muted = !!value; },
    isMuted: function () { return muted; },
    play: function (direction) { playFlip(direction || "next"); }
  };

  return {
    id: "RevealComicPageTurn"
  };
})();
