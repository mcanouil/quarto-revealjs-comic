--[[
  bam.lua
  Shortcode for inline action callouts in the comic Reveal.js theme.

  Usage:
    {{< bam "POW!" colour=red >}}

  Arguments:
    args[1]      Text to display (default: "BAM!").
    kwargs.colour One of yellow | red | blue (default: yellow).

  Emits a styled <div class="action-callout action-<colour>"> the comic theme
  renders as a skewed, ink-outlined comic burst.
]]

local str = require(quarto.utils.resolve_path("_modules/string.lua"):gsub("%.lua$", ""))

local valid_colours = { yellow = true, red = true, blue = true }

return {
  ["bam"] = function(args, kwargs)
    if not quarto.doc.is_format("revealjs") then
      return nil
    end
    local text = "BAM!"
    if args and args[1] then
      text = pandoc.utils.stringify(args[1])
    end
    local colour = "yellow"
    if kwargs and kwargs["colour"] then
      local requested = pandoc.utils.stringify(kwargs["colour"])
      if valid_colours[requested] then
        colour = requested
      end
    end
    local html = string.format(
      '<div class="action-callout action-%s">%s</div>',
      colour,
      str.escape_html(text)
    )
    return pandoc.RawBlock("html", html)
  end,
}
