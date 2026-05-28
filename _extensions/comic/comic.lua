--[[
  comic.lua
  Reveal.js filter for the comic theme.

  Div filter on .speech: wraps content in a styled speech bubble and appends
  an SVG tail so authors do not have to hand-write SVG markup.
]]

local helpers = require(quarto.utils.resolve_path("_modules/pandoc-helpers.lua"):gsub("%.lua$", ""))

local speech_tail = [[<svg class="speech-tail" viewBox="0 0 60 60" aria-hidden="true">
  <polygon points="0,0 60,0 30,55" fill="#ffffff" stroke="#0b0b0b" stroke-width="6" stroke-linejoin="round"/>
</svg>]]

local function Div(el)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end
  if not helpers.has_class(el.classes, "speech") then
    return nil
  end
  local bubble = pandoc.Div(el.content, pandoc.Attr("", { "speech-bubble" }, {}))
  el.content = { bubble, pandoc.RawBlock("html", speech_tail) }
  return el
end

return {
  { Div = Div },
}
