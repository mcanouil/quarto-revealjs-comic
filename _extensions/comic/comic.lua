--[[
  comic.lua
  Reveal.js filter for the comic theme.

  Three responsibilities:

  1. Wraps dialogue divs (.speech, .thought, .shout, .whisper, .narration) in
     a typed inner wrapper so the comic theme can paint each bubble variant
     with its own shape, border, and tail.

  2. Renders .character divs as a CSS-drawn caped hero avatar beside a
     Markdown-filled bubble. Attributes: pose (left|right), state (talk|action),
     and bubble (speech|thought|shout|whisper) select placement, pose, and which
     bubble variant styles the dialogue.

  3. For .section slides, splits the heading text on the first ':' into a
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

-- Whitelists for .character attributes; unknown values fall back to defaults.
local character_poses = { left = true, right = true }
local character_states = { talk = true, action = true }

-- Pick a whitelisted attribute value, or the default.
local function pick(value, whitelist, default)
  if value and whitelist[value] then
    return value
  end
  return default
end

-- Build the CSS-drawn hero avatar (cape, body, head are painted in comic.scss).
local function character_figure()
  local layers = {
    pandoc.Span({}, pandoc.Attr("", { "character-cape" }, {})),
    pandoc.Span({}, pandoc.Attr("", { "character-body" }, {})),
    pandoc.Span({}, pandoc.Attr("", { "character-head" }, {})),
  }
  return pandoc.Div(layers, pandoc.Attr("", { "character-figure" }, { ["aria-hidden"] = "true" }))
end

local function Div(el)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end

  if helpers.has_class(el.classes, "character") then
    local pose = pick(el.attributes.pose, character_poses, "left")
    local state = pick(el.attributes.state, character_states, "talk")
    local bubble = bubble_classes[el.attributes.bubble] or bubble_classes.speech

    local bubble_div = pandoc.Div(el.content, pandoc.Attr("", { bubble, "character-bubble" }, {}))
    return pandoc.Div(
      { character_figure(), bubble_div },
      pandoc.Attr("", { "character", "character-" .. pose, "character-" .. state }, {})
    )
  end

  for source_class, wrapper_class in pairs(bubble_classes) do
    if helpers.has_class(el.classes, source_class) then
      return pandoc.Div(el.content, pandoc.Attr("", { wrapper_class }, {}))
    end
  end
  return nil
end

local function Header(el)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end
  if (el.level ~= 1 and el.level ~= 2) or not helpers.has_class(el.classes, "section") then
    return nil
  end

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
    el.content = { pandoc.Span(el.content, pandoc.Attr("", { "section-title" }, {})) }
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
    new_inlines:insert(pandoc.Span(banner_inlines, pandoc.Attr("", { "section-banner" }, {})))
  end
  new_inlines:insert(pandoc.Span(title_inlines, pandoc.Attr("", { "section-title" }, {})))

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

      local trailing_caption
      if #body > 0 then
        local last = body[#body]
        if last.t == "Div" and helpers.has_class(last.classes, "caption") then
          trailing_caption = last
          body:remove(#body)
        end
      end

      if #body > 0 then
        local stage = header_stage_class(blk)
        local classes = stage and { "comic-stage", "comic-fit" } or { "comic-fit" }
        out:insert(pandoc.Div(body, pandoc.Attr("", classes, {})))
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
