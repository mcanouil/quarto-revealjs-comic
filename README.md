# Comic Reveal.js Theme

A Quarto Reveal.js format that styles slides as a super-hero comic book.
Authors opt into distinct visuals (cover splash, section splash, single panel, action callout, speech bubble, halftone background) by adding a class to the slide heading.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-comic
```

This will install the extension under the `_extensions` subdirectory.
If you are using version control, you will want to check in this directory.

## Usage

Pick the format in your presentation YAML:

```yaml
---
title: "Caped Crusader"
format: comic-revealjs
---
```

### Slide classes

| Class          | Effect                                                                     |
| -------------- | -------------------------------------------------------------------------- |
| `.title-slide` | Auto-applied to the cover slide; diagonal red block, halftone overlay.     |
| `.section`     | Chapter splash with starburst background.                                  |
| `.panel`       | Single comic panel: paper background, bold ink border, drop shadow.        |
| `.action`      | BAM/POW/ZAP-style action slide: skewed display text on a burst background. |
| `.speech`      | Speech bubble; an SVG tail is injected automatically by the filter.        |
| `.halftone`    | Ben Day dots background modifier; composable with any other class.        |

Apply a class to a slide by appending it to the heading:

```markdown
## Chapter 1: The Setup {.section}

## A Single Panel {.panel}

## {.action}
POW!

## Hero says... {.speech}
With great Quarto comes great responsibility.
```

### `bam` shortcode

For inline action callouts inside any slide:

```markdown
{{< bam "ZAP!" colour=blue >}}
```

Available colours: `yellow` (default), `red`, `blue`.

## Example

Source: [template.qmd](template.qmd).
Rendered output: [HTML](https://m.canouil.dev/quarto-revealjs-comic/).

## Author

Mickaël Canouil, _Ph.D._ ([https://mickael.canouil.fr](https://mickael.canouil.fr), [ORCID](https://orcid.org/0000-0002-3396-4549)).

## Acknowledgements

Built on top of the Reveal.js engine shipped with Quarto.
Web fonts served by Google Fonts: Bangers, Permanent Marker, Comic Neue.
