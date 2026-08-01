# Reveal.js Comic Format For Quarto

A Quarto Reveal.js format that styles slides as a super-hero comic book.

Authors opt into distinct visuals (cover splash, section splash, single panel, action callout, speech bubble, halftone background) by adding a class to the slide heading.

## Creating a New Presentation

```bash
quarto use template mcanouil/quarto-revealjs-comic@1.0.0
```

## Installation For Existing Presentation

```bash
quarto add mcanouil/quarto-revealjs-comic@1.0.0
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Documentation

The full documentation lives at <https://m.canouil.dev/quarto-revealjs-comic/>: every slide class, the bubble divs, the fragment entrances, how they compose, and a deck built by the site itself.

[`template.qmd`](template.qmd) is a complete starting point you can copy.

## Licence

[MIT](https://github.com/mcanouil/quarto-revealjs-comic?tab=MIT-1-ov-file#readme).
