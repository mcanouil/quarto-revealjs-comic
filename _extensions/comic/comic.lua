--[[
  comic.lua
  Reveal.js filter for the comic theme.

  Wraps :::{.speech} divs in an inline `.speech-bubble` span so the comic
  theme can style the bubble shape and CSS-triangle tail.
]]

local helpers = require(quarto.utils.resolve_path("_modules/pandoc-helpers.lua"):gsub("%.lua$", ""))

local function Div(el)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end
  if not helpers.has_class(el.classes, "speech") then
    return nil
  end
  return pandoc.Div(el.content, pandoc.Attr("", { "speech-bubble" }, {}))
end

return {
  { Div = Div },
}
