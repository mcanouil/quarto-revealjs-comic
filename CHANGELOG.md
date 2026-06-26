# Changelog

## Unreleased

## 0.4.7 (2026-06-26)

- style: bleed the halftone dots across the full window on every halftone variant, instead of only the slide box, so the dot field reaches the screen edges as one continuous grid.
- style: fill the background around the panel card, speech bubble, and action/explosion burst with halftone dots, so `.panel`, `.speech`, `.action`, and `.explosion` slides sit on the same dotted field as `.halftone`.
- style: drop the faint grey 45-degree ink-hatch from the title-slide cover backdrop, keeping the red rays and halftone dots.

## 0.4.6 (2026-06-26)

- fix: centre image-only paragraphs on halftone slides by excluding them from the paper-chip rule, whose higher specificity previously overrode the dedicated exclusion and left the figure shrunk to a `fit-content` block against the left edge.

## 0.4.5 (2026-06-26)

- fix: honour slide-level `background-color` on halftone slides so the dots render over the chosen colour.

## 0.4.4 (2026-06-26)

- style: hide the menu button and slide number on section slides.
- style: centre the thought bubble on the slide, narrow it, and centre its text.
- style: bolden the shout bubble text to match the other display text.
- style: drop the paper chip behind image-only paragraphs on halftone slides.
- style: limit the halftone paper chip to plain prose, sparing captions, bubbles, callouts, and panel slides.

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
