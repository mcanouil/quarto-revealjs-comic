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

| Class | Effect |
| --- | --- |
| `.title-slide` | Auto-applied to the cover slide; diagonal red block, halftone overlay. |
| `.section` | Chapter splash with starburst background. |
| `.panel` | Single comic panel: paper background, bold ink border, drop shadow. |
| `.action` | BAM/POW/ZAP-style action slide: skewed display text on a burst background. |
| `.speech` | Speech bubble; an SVG tail is injected automatically by the filter. |
| `.character` | CSS-drawn caped hero beside a Markdown bubble (see below). |
| `.halftone` | Ben Day dots background modifier; composable with any other class. |

Apply a class to a slide by appending it to the heading:

```markdown
## Chapter 1: The Setup {.section}

## A Single Panel {.panel}

## {.action}
POW!

## Hero says... {.speech}
With great Quarto comes great responsibility.
```

### `.character` div

Put a CSS-drawn caped hero on the slide with a Markdown-filled bubble.
The div body is the dialogue, so emphasis, links, and lists all work:

```markdown
::: {.character}
I saw a flash, and then **nothing**.
:::

::: {.character pose="right" bubble="thought"}
The next pulse is in three minutes.
:::

::: {.character state="action" bubble="shout"}
Stop right there!
:::
```

Attributes (all optional):

| Attribute | Values | Default | Effect |
| --- | --- | --- | --- |
| `pose` | `left`, `right` | `left` | Which side the hero stands; the bubble sits opposite and points back. |
| `state` | `talk`, `action` | `talk` | `action` tilts the hero into a lunge and adds speed lines. |
| `bubble` | `speech`, `thought`, `shout`, `whisper` | `speech` | Reuses the matching bubble variant to style the dialogue. |

### `bam` and `boom` shortcodes

For inline action callouts inside any slide.
`bam` renders a skewed marker burst; `boom` renders a jagged star burst.
Both share the same attributes:

```markdown
{{< bam "ZAP!" colour=blue >}}
{{< boom "KA-BLAM!" colour=red top=12% right=8% rotate=-10 fragment=burst >}}
```

| Attribute | Values | Default | Effect |
| --- | --- | --- | --- |
| _(text)_ | any string | `BAM!` / `BOOM!` | The callout text. |
| `colour` | `yellow`, `red`, `blue` | `yellow` (`bam`), `red` (`boom`) | Fill/ink colour. |
| `top`, `right`, `bottom`, `left` | CSS length (e.g. `10%`, `40px`, `2em`) | none | When any is set, the callout floats with `position: absolute`. |
| `rotate` | number (degrees) or `Ndeg` | `-4deg` (`bam`), `-6deg` (`boom`) | Tilt angle. |
| `size` | CSS font-size (e.g. `3em`, `64px`) | theme default | Callout size. |
| `fragment` | `true`, `burst`, `pop`, `splat` (or `false`/`off`) | off | Reveals the callout as a fragment with the matching comic entrance (`true` maps to `burst`). |
| `index` | non-negative integer | none | Sets `data-fragment-index` to order the callout among the slide's fragments. |

## Example

Source: [template.qmd](template.qmd).
Rendered output: [HTML](https://m.canouil.dev/quarto-revealjs-comic/).

The template now demonstrates a broader Quarto workflow in a Reveal.js context, including:

- `layout-*` attributes (`layout-ncol`, `layout-nrow`, `layout-valign`).
- Tabbed panels with `.panel-tabset`.
- Cross-references for sections, figures, and tables.
- Labelled tables and figures.
- Callouts and citation-backed narrative (`references.bib`).

For dense technical content, prefer plain slides or `.panel` slides for readability.
Use highly stylised classes such as `.action` and `.speech` for emphasis or short narrative moments.

## Author

Mickaël Canouil, _Ph.D._ ([https://mickael.canouil.fr](https://mickael.canouil.fr), [ORCID](https://orcid.org/0000-0002-3396-4549)).

## Acknowledgements

Built on top of the Reveal.js engine shipped with Quarto.
Web fonts served by Google Fonts: Bangers, Permanent Marker, Comic Neue.
