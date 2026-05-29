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

local str = require(quarto.utils.resolve_path("_modules/string.lua"):gsub("%.lua$", ""))
local callout = require(quarto.utils.resolve_path("_modules/callout.lua"):gsub("%.lua$", ""))

return {
  ["bam"] = function(args, kwargs)
    if not quarto.doc.is_format("revealjs") then
      return nil
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
