--[[
  bam.lua
  Shortcode for inline action callouts in the comic Reveal.js theme.

  Usage:
    {{< bam "POW!" colour=red >}}
    {{< bam "ZAP!" colour=blue top=10% right=8% rotate=-15 >}}

  Arguments:
    args[1]       Text to display (default: "BAM!").
    kwargs.colour One of yellow | red | blue (default: yellow).
    kwargs.top, .right, .bottom, .left
                  CSS length values (e.g. 10%, 40px, 2em). When any one
                  is supplied the callout is rendered with
                  `position: absolute` so it floats over the slide.
    kwargs.rotate Angle (number => degrees, or `Ndeg`). Overrides the
                  default rotation.
    kwargs.size   CSS font-size value (e.g. 3em, 64px). Overrides the
                  default callout size.

  Emits a <div class="action-callout action-<colour>"> the comic theme
  renders as a skewed, ink-outlined comic burst.
]]

local str = require(quarto.utils.resolve_path("_modules/string.lua"):gsub("%.lua$", ""))

local valid_colours = { yellow = true, red = true, blue = true }

local function safe_length(value)
  if not value then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if s == "" then
    return nil
  end
  if s:match("^%-?%d+%.?%d*$")
    or s:match("^%-?%d*%.?%d+$")
    or s:match("^%-?%d+%.?%d*[a-z]+$")
    or s:match("^%-?%d*%.?%d+[a-z]+$")
    or s:match("^%-?%d+%.?%d*%%$")
    or s:match("^%-?%d*%.?%d+%%$") then
    return s
  end
  return nil
end

local function safe_angle(value)
  if not value then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if s:match("^%-?%d+%.?%d*$") or s:match("^%-?%d*%.?%d+$") then
    return s .. "deg"
  end
  if s:match("^%-?%d+%.?%d*deg$") or s:match("^%-?%d*%.?%d+deg$") then
    return s
  end
  return nil
end

local function build_style(kwargs)
  local parts = {}
  local positional = false
  for _, key in ipairs({ "top", "right", "bottom", "left" }) do
    local v = safe_length(kwargs[key])
    if v then
      parts[#parts + 1] = key .. ":" .. v
      positional = true
    end
  end
  if positional then
    table.insert(parts, 1, "position:absolute")
  end
  local size = safe_length(kwargs["size"])
  if size then
    parts[#parts + 1] = "font-size:" .. size
  end
  local angle = safe_angle(kwargs["rotate"])
  if angle then
    parts[#parts + 1] = "transform:rotate(" .. angle .. ")"
  end
  if #parts == 0 then
    return ""
  end
  return ' style="' .. table.concat(parts, ";") .. '"'
end

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
    local style = build_style(kwargs or {})
    local html = string.format(
      '<div class="action-callout action-%s"%s>%s</div>',
      colour,
      style,
      str.escape_html(text)
    )
    return pandoc.RawBlock("html", html)
  end,
}
