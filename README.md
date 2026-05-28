<!--
AGENT GUIDELINES:
This README is the primary documentation for the extension.
Update placeholder content with actual extension details.

Required updates:
1. Replace %%placeholders%% with actual values.
2. Write a clear description explaining what the format provides.
3. Document all format options in the Configuration table.
4. Document any included RevealJS plugins.
5. Add rendered output links to the Example section.
6. Update or remove the Acknowledgements section.
-->

# Revealjs Comic

A Quarto extension.

## Installation

```bash
quarto add mcanouil/quarto-revealjs-comic
```

This will install the extension under the `_extensions` subdirectory.
If you are using version control, you will want to check in this directory.

## Usage

Use the format in your presentation YAML:

```yaml
format:
  revealjs-comic-revealjs: default
```

With options:

```yaml
format:
  revealjs-comic-revealjs:
    transition: slide
```

## Configuration

### Format Options

<!-- TODO: Document all format options -->

| Option       | Type   | Default   | Description              |
| ------------ | ------ | --------- | ------------------------ |
| `transition` | string | `"slide"` | Slide transition effect. |

## Example

Here is the source code for a minimal example: [template.qmd](template.qmd).

<!-- TODO: Add rendered output links -->

Rendered output:

- [HTML](https://m.canouil.dev/quarto-revealjs-comic/).

