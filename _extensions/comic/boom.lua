--[[
  boom.lua
  Shortcode for inline explosion callouts in the comic Reveal.js theme.

  Usage:
    {{< boom "BOOM!" colour=red >}}
    {{< boom "KA-BLAM!" colour=yellow top=12% right=8% rotate=-10 size=3em >}}
    {{< boom "BLAM!" colour=yellow fragment=pop index=2 >}}

  Arguments:
    args[1]        Text to display (default: "BOOM!").
    kwargs.colour  One of yellow | red | blue (default: red).
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

  Emits a <div class="boom-callout boom-<colour>"> the comic theme renders
  as a jagged spike-burst with the text clipped inside the star polygon.
]]

local str = require(quarto.utils.resolve_path("_modules/string.lua"):gsub("%.lua$", ""))
local callout = require(quarto.utils.resolve_path("_modules/callout.lua"):gsub("%.lua$", ""))

return {
  ["boom"] = function(args, kwargs)
    if not quarto.doc.is_format("revealjs") then
      return nil
    end
    local text = "BOOM!"
    if args and args[1] then
      text = pandoc.utils.stringify(args[1])
    end
    local classes, style, data = callout.attributes("boom-callout", "boom", "red", kwargs)
    local html = string.format(
      '<div class="%s"%s%s><span class="boom-text">%s</span></div>',
      classes,
      style,
      data,
      str.escape_html(text)
    )
    return pandoc.RawBlock("html", html)
  end,
}
