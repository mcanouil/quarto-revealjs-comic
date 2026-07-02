# Reveal.js Comic Format For Quarto

A Quarto Reveal.js format that styles slides as a super-hero comic book.
Authors opt into distinct visuals (cover splash, section splash, single panel, action callout, speech bubble, halftone background) by adding a class to the slide heading.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-comic@1.0.0
```

This will install the extension under the `_extensions` subdirectory.
If you are using version control, you will want to check in this directory.

Alternatively, start a new presentation from the bundled template:

```bash
quarto use template mcanouil/quarto-revealjs-comic@1.0.0
```

This installs the extension and seeds the project with a ready-to-edit `template.qmd`.

## Usage

Pick the format in your presentation YAML:

```yaml
---
title: "Caped Crusader"
format: comic-revealjs
---
```

### Slide classes

| Class          | Effect                                                                                                         |
| -------------- | -------------------------------------------------------------------------------------------------------------- |
| `.title-slide` | Auto-applied to the cover slide; diagonal red block, halftone overlay.                                         |
| `.section`     | Chapter splash with starburst background; a `Banner: Title` heading splits into a banner chip above the title. |
| `.panel`       | Single comic panel: paper background, bold ink border, drop shadow.                                            |
| `.action`      | BAM/POW/ZAP-style action slide: skewed display text on a burst background.                                     |
| `.explosion`   | Explosion splash: jagged star burst behind centred display text.                                               |
| `.speech`      | Speech-bubble slide; an SVG tail is injected automatically by the filter. Also works as a div (see below).     |
| `.halftone`    | Ben Day dots background modifier; composable with any other class.                                             |

Apply a class to a slide by appending it to the heading:

```markdown
## Chapter 1: The Setup {.section}

## A Single Panel {.panel}

## {.action}

POW!

## Hero says... {.speech}

With great Quarto comes great responsibility.
```

### Bubble divs

Drop a styled bubble anywhere inside a slide by wrapping Markdown in a div.
The filter paints each variant with its own shape and border; the body is ordinary Markdown, so emphasis, links, and lists all work:

```markdown
::: {.speech}
Use me when a character speaks mid-panel.
:::

::: {.thought}
If the signal repeats every 11 minutes, the next pulse is in 3.
:::

::: {.shout}
Stop right there!
:::

::: {.whisper}
Until next time.
:::

::: {.narration}
Three minutes later, the city is quiet again.
:::
```

| Class        | Bubble                                 |
| ------------ | -------------------------------------- |
| `.speech`    | Rounded speech bubble with a tail.     |
| `.thought`   | Cloud-style thought bubble.            |
| `.shout`     | Spiky shout bubble for raised voices.  |
| `.whisper`   | Soft dashed bubble for quiet asides.   |
| `.narration` | Rectangular caption box for narration. |

Bubble divs accept the same standard reveal.js classes and attributes as any other div, so `.fragment`, `fragment-index`, an `#id`, and custom classes apply to the whole bubble:

```markdown
::: {.shout .fragment fragment-index="2"}
Stop right there!
:::
```

### Fragment entrances

Comic-themed entrances for any [reveal.js fragment](https://quarto.org/docs/presentations/revealjs/advanced.html#fragments).
Combine `.fragment` with one of the helper classes on a span, list item, or div:

| Class            | Entrance                             |
| ---------------- | ------------------------------------ |
| `.comic-pop`     | Pops in with a quick overshoot.      |
| `.halftone-wipe` | Wipes in behind a halftone sweep.    |
| `.ink-splat`     | Splats in like wet ink.              |
| `.zap-highlight` | Flashes a highlight across the text. |

```markdown
- [Locate the source of the broadcast.]{.fragment .comic-pop}

[The neon hum dims below the clouds.]{.fragment .ink-splat}
```

### Per-slide options

Tune the comic plugins with data attributes:

| Attribute                  | Where         | Effect                                                               |
| -------------------------- | ------------- | -------------------------------------------------------------------- |
| `data-comic-fit="false"`   | slide heading | Leaves the slide at its natural size instead of auto-scaling to fit. |
| `data-no-sound`            | slide heading | Silences the page-turn whoosh for that one slide.                    |
| `data-comic-sound="false"` | document body | Mutes the page-turn whoosh for the whole deck.                       |

```markdown
## Natural Size {.panel data-comic-fit="false"}

## Silent Panel {.panel data-no-sound=true}
```

### `bam` and `boom` shortcodes

For inline action callouts inside any slide.
`bam` renders a skewed marker burst; `boom` renders a jagged star burst.
Both share the same attributes:

```markdown
{{< bam "ZAP!" colour=blue >}}
{{< boom "KA-BLAM!" colour=red top=12% right=8% rotate=-10 fragment=burst >}}
```

| Attribute                        | Values                                             | Default                           | Effect                                                                                       |
| -------------------------------- | -------------------------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------- |
| _(text)_                         | any string                                         | `BAM!` / `BOOM!`                  | The callout text.                                                                            |
| `colour`                         | `yellow`, `red`, `blue`                            | `yellow` (`bam`), `red` (`boom`)  | Fill/ink colour.                                                                             |
| `top`, `right`, `bottom`, `left` | CSS length (e.g. `10%`, `40px`, `2em`)             | none                              | When any is set, the callout floats with `position: absolute`.                               |
| `rotate`                         | number (degrees) or `Ndeg`                         | `-4deg` (`bam`), `-6deg` (`boom`) | Tilt angle.                                                                                  |
| `size`                           | CSS font-size (e.g. `3em`, `64px`)                 | theme default                     | Callout size.                                                                                |
| `fragment`                       | `true`, `burst`, `pop`, `splat` (or `false`/`off`) | off                               | Reveals the callout as a fragment with the matching comic entrance (`true` maps to `burst`). |
| `index`                          | non-negative integer                               | none                              | Sets `data-fragment-index` to order the callout among the slide's fragments.                 |

## Example

Here is the source code for a comprehensive example: [template.qmd](template.qmd).

Output of `template.qmd`:

- [Reveal.js](https://m.canouil.dev/quarto-revealjs-comic/)
