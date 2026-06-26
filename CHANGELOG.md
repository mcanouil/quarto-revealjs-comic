# Changelog

## Unreleased

- style: centre the thought bubble on the slide, narrow it, and centre its text.
- style: bolden the shout bubble text to match the other display text.

## 0.4.3 (2026-06-26)

- fix: preserve user attributes (`.fragment`, `fragment-index`, `#id`, custom classes) on bubble divs.
- style: centre shout text and narrow the speech bubble so text clears the outline.

## 0.4.2 (2026-06-05)

- style: remove border-radius from code filename file in code blocks.

## 0.4.1 (2026-06-05)

- style: add fragment index to cover burst for improved title slide.

## 0.4.0 (2026-06-05)

- fix: replace comic-cover JS plugin with pure-CSS `:has()` cover bleed.
- fix: correct cover corner bracket arm lengths and overflow using fixed pixel positions.
- fix: apply `.caption` and list styles inside `.speech` slides.

## 0.3.0 (2026-06-05)

- feat: adjust slide logo height for consistent display.
- feat: enhance author information display on title slide.
- feat: centre content in comic panels with flexbox.

## 0.2.0 (2026-06-04)

- feat: enhance code-window styling for comic panels.
- feat: centre content in comic panels with flexbox.
- feat: enhance bleed functionality for comic cover.

## 0.1.0 (2026-05-29)

### New Features

- feat: Initial release of the comic Reveal.js theme.
- feat: Six per-slide classes (`.title-slide`, `.section`, `.panel`, `.action`, `.speech`, `.halftone`).
- feat: `{{< bam >}}` shortcode for inline action callouts.
- feat: SVG speech-bubble tail injected automatically by the filter on `.speech` divs.
