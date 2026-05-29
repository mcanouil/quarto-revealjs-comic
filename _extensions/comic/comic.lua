--[[
  comic.lua
  Reveal.js filter for the comic theme.

  Two responsibilities:

  1. Wraps dialogue divs (.speech, .thought, .shout, .whisper, .narration) in
     a typed inner wrapper so the comic theme can paint each bubble variant
     with its own shape, border, and tail.

  2. For .section slides, splits the heading text on the first ':' into a
     <span class="section-banner"> + <span class="section-title"> pair so the
     comic theme can show a banner chip above the title (e.g.
     "## Chapter 1: The Setup {.section}" → banner "Chapter 1", title
     "The Setup").
]]

local helpers = require(quarto.utils.resolve_path("_modules/pandoc-helpers.lua"):gsub("%.lua$", ""))

local bubble_classes = {
  speech    = "speech-bubble",
  thought   = "bubble-thought",
  shout     = "bubble-shout",
  whisper   = "bubble-whisper",
  narration = "bubble-narration",
}

local function Div(el)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end

  for source_class, wrapper_class in pairs(bubble_classes) do
    if helpers.has_class(el.classes, source_class) then
      return pandoc.Div(el.content, helpers.attr(nil, { wrapper_class }))
    end
  end
  return nil
end

-- Stable, zero-padded chapter number stamped onto each .section slide in
-- document order. The comic theme renders it via content: attr(data-comic-number).
-- Done at build time because a CSS counter renumbers under navigation:
-- reveal.js sets display:none on off-screen slides and CSS counters skip them.
local section_counter = 0

local function Header(el)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end
  if (el.level ~= 1 and el.level ~= 2) or not helpers.has_class(el.classes, "section") then
    return nil
  end

  section_counter = section_counter + 1
  el.attributes["data-comic-number"] = string.format("%02d", section_counter)

  -- Find the first Str inline containing a colon.
  local split_idx, colon_pos
  for i, inline in ipairs(el.content) do
    if inline.t == "Str" then
      local p = inline.text:find(":")
      if p then
        split_idx, colon_pos = i, p
        break
      end
    end
  end

  if not split_idx then
    -- No colon: wrap the whole heading as the title span; no banner.
    el.content = { pandoc.Span(el.content, helpers.attr(nil, { "section-title" })) }
    return el
  end

  local banner_inlines = pandoc.List({})
  for i = 1, split_idx - 1 do
    banner_inlines:insert(el.content[i])
  end

  local pivot = el.content[split_idx].text
  local banner_text = pivot:sub(1, colon_pos - 1)
  local rest_text = pivot:sub(colon_pos + 1):gsub("^%s+", "")
  if banner_text ~= "" then
    banner_inlines:insert(pandoc.Str(banner_text))
  end

  local title_inlines = pandoc.List({})
  if rest_text ~= "" then
    title_inlines:insert(pandoc.Str(rest_text))
  end
  for i = split_idx + 1, #el.content do
    title_inlines:insert(el.content[i])
  end
  while #title_inlines > 0 and title_inlines[1].t == "Space" do
    title_inlines:remove(1)
  end

  local new_inlines = pandoc.List({})
  if #banner_inlines > 0 then
    new_inlines:insert(pandoc.Span(banner_inlines, helpers.attr(nil, { "section-banner" })))
  end
  new_inlines:insert(pandoc.Span(title_inlines, helpers.attr(nil, { "section-title" })))

  el.content = new_inlines
  return el
end

-- Slide-level classes whose body content is centred by an always-flex inner
-- wrapper (.comic-stage). Moving centring off the <section> (whose `display`
-- reveal.js toggles between block/none/flex during a transition) and onto an
-- inner div whose display is never touched keeps the content centred through
-- the page-turn instead of snapping when `.present` lands.
local stage_classes = { speech = true, action = true, explosion = true }

-- A level-1 or level-2 header starts a new slide in this deck. Return its level
-- (or nil); used to find slide boundaries when wrapping each slide's body.
local function slide_header_level(blk)
  if blk.t == "Header" and (blk.level == 1 or blk.level == 2) then
    return blk.level
  end
  return nil
end

-- The stage class carried by a header, or nil.
local function header_stage_class(blk)
  for _, class in ipairs(blk.classes) do
    if stage_classes[class] then
      return class
    end
  end
  return nil
end

-- Wrap every slide's body in a single scalable element so the comic-fit plugin
-- has one node per slide to measure and shrink to fit the slide bounds.
-- Stage slides (.speech/.action/.explosion) reuse .comic-stage, whose
-- always-flex display keeps content centred through the page-turn; all other
-- slides get a plain .comic-fit wrapper. The header stays a direct child of the
-- section so the slide class, heading rules, and chapter counter still match.
-- A trailing .caption div is left outside the wrapper so it stays pinned to the
-- slide corner and unscaled (the .panel caption is absolutely positioned).
local function Pandoc(doc)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end

  local out = pandoc.List({})
  local i = 1
  while i <= #doc.blocks do
    local blk = doc.blocks[i]
    local level = slide_header_level(blk)
    if level then
      out:insert(blk)
      local body = pandoc.List({})
      local j = i + 1
      while j <= #doc.blocks do
        local nxt = doc.blocks[j]
        if slide_header_level(nxt) then
          break
        end
        body:insert(nxt)
        j = j + 1
      end

      -- Pull a trailing .caption out of the wrapper so it stays pinned to the
      -- slide corner and unscaled. Skip trailing Quarto-generated blocks first
      -- (e.g. on a #refs slide Quarto appends a .quarto-auto-generated-content
      -- div and an empty .hidden div after the caption), so the caption is still
      -- found when it is not literally the last block.
      local function ignorable(b)
        if b.t ~= "Div" then
          return false
        end
        return #b.content == 0
          or helpers.has_class(b.classes, "hidden")
          or helpers.has_class(b.classes, "quarto-auto-generated-content")
      end

      local trailing_caption
      do
        local k = #body
        while k > 0 and ignorable(body[k]) do
          k = k - 1
        end
        if k > 0 and body[k].t == "Div" and helpers.has_class(body[k].classes, "caption") then
          trailing_caption = body[k]
          body:remove(k)
        end
      end

      if #body > 0 then
        local stage = header_stage_class(blk)
        local classes = stage and { "comic-stage", "comic-fit" } or { "comic-fit" }
        out:insert(pandoc.Div(body, helpers.attr(nil, classes)))
      end
      if trailing_caption then
        out:insert(trailing_caption)
      end
      i = j
    else
      out:insert(blk)
      i = i + 1
    end
  end

  doc.blocks = out
  return doc
end

return {
  { Div = Div, Header = Header },
  { Pandoc = Pandoc },
}
