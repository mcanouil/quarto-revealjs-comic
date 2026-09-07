--[[
  bam.lua
  Shortcode for inline action callouts in the comic Reveal.js theme.

  Usage:
    {{< bam "POW!" colour=red >}}
    {{< bam "ZAP!" colour=blue top=10% right=8% rotate=-15 >}}
    {{< bam "POW!" colour=red top=35% right=8% rotate=12 fragment=burst >}}

  Arguments:
    args[1]        Text to display (default: "BAM!").
    kwargs.colour  One of yellow | red | blue (default: yellow).
    kwargs.top, .right, .bottom, .left
                   CSS length values (e.g. 10%, 40px, 2em). When any one
                   is supplied the callout is rendered with
                   `position: absolute` so it floats over the slide.
    kwargs.rotate  Angle (number => degrees, or `Ndeg`). Overrides the
                   default rotation.
    kwargs.size    CSS font-size value (e.g. 3em, 64px). Overrides the
                   default callout size.
    kwargs.fragment
                   true | burst | pop | splat to reveal the callout as a
                   Reveal.js fragment with the matching comic entrance
                   (true maps to burst). false / off disables it.
    kwargs.index   Non-negative integer set as `data-fragment-index` to
                   order the callout among the slide's fragments.

  Emits a <div class="action-callout action-<colour>"> the comic theme
  renders as a skewed, ink-outlined comic burst.
]]

local str = require(quarto.utils.resolve_path("_vendor/quarto-lua-modules/string.lua"):gsub("%.lua$", ""))
local callout = require(quarto.utils.resolve_path("_modules/callout.lua"):gsub("%.lua$", ""))
local schema = require(quarto.utils.resolve_path("_vendor/quarto-wizard/schema.lua"):gsub("%.lua$", ""))
local check = require(quarto.utils.resolve_path("_vendor/quarto-lua-modules/schema-check.lua"):gsub("%.lua$", ""))

--- Extension name constant
local EXTENSION_NAME = "comic"

--- The schema check, built once and reused by every `bam` call. It reads
--- `_schema.yml` on the way in and checks each call against the entry that
--- describes it.
---
--- The validator is injected rather than required by the check module, so the
--- two vendored sources stay independent of where the other was placed.
---
--- The schema declares no `options:` block, so there is no document
--- configuration to check and the checker only ever sees calls.
---
--- The extension's filter is scoped to the `revealjs` format while its
--- shortcodes are not, so a document in another format expands this shortcode
--- without the filter ever loading. The check therefore runs from the
--- shortcode handler, which is the only place that sees every call.
---
--- A schema that cannot be read is reported by the module as an error and the
--- render carries on: a configuration file must not stop a document.
local checker = check.new(schema, EXTENSION_NAME)

return {
  ["bam"] = function(args, kwargs)
    checker:call("bam", args, kwargs)

    if not quarto.doc.is_format("revealjs") then
      return pandoc.Null()
    end
    local text = "BAM!"
    if args and args[1] then
      text = pandoc.utils.stringify(args[1])
    end
    local classes, style, data = callout.attributes("action-callout", "action", "yellow", kwargs)
    local html = string.format(
      '<div class="%s"%s%s>%s</div>',
      classes,
      style,
      data,
      str.escape_html(text)
    )
    return pandoc.RawBlock("html", html)
  end,
}
