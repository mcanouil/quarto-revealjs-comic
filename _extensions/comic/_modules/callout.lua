--- MC Callout - Shared helpers for the comic theme's boom/bam callout shortcodes
--- @module "callout"
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @version 1.0.0

local M = {}

-- ============================================================================
-- VALIDATION
-- ============================================================================

--- True when `s` is a signed decimal number followed by `suffix` (a Lua
--- pattern). Two alternatives keep at least one digit on either side of the
--- decimal point (so `5`, `.5`, and `1.5` match but a bare `.` does not).
--- @param s string
--- @param suffix string Trailing Lua pattern (e.g. "", "[a-z]+", "%%", "deg").
--- @return boolean
local function numeric(s, suffix)
  return s:match("^%-?%d+%.?%d*" .. suffix .. "$") ~= nil
    or s:match("^%-?%d*%.?%d+" .. suffix .. "$") ~= nil
end

--- Colours both callouts accept; unknown values fall back to the default.
local valid_colours = { yellow = true, red = true, blue = true }

--- Pick a whitelisted colour from the kwargs, or the supplied default.
--- @param kwargs table Shortcode kwargs.
--- @param default string Fallback colour name.
--- @return string
local function pick_colour(kwargs, default)
  if kwargs and kwargs["colour"] then
    local requested = pandoc.utils.stringify(kwargs["colour"])
    if valid_colours[requested] then
      return requested
    end
  end
  return default
end

--- Validate a CSS length value (e.g. 10%, 40px, 2em). Returns the string or nil.
--- @param value any
--- @return string|nil
local function safe_length(value)
  if not value then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if s == "" then
    return nil
  end
  if numeric(s, "") or numeric(s, "[a-z]+") or numeric(s, "%%") then
    return s
  end
  return nil
end

--- Validate a rotation angle. Bare numbers gain a `deg` suffix. Returns nil
--- for anything else.
--- @param value any
--- @return string|nil
local function safe_angle(value)
  if not value then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if numeric(s, "") then
    return s .. "deg"
  end
  if numeric(s, "deg") then
    return s
  end
  return nil
end

--- Validate a non-negative integer fragment index. Returns the string or nil.
--- @param value any
--- @return string|nil
local function safe_index(value)
  if not value then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if s:match("^%d+$") then
    return s
  end
  return nil
end

-- ============================================================================
-- FRAGMENTS
-- ============================================================================

-- Map a `fragment=` value to the entrance CSS class. `true` and unknown truthy
-- values fall back to the dedicated callout burst.
local fragment_variants = {
  burst = "callout-burst",
  pop   = "comic-pop",
  splat = "ink-splat",
}

local fragment_off = { ["false"] = true, ["off"] = true, ["no"] = true, ["0"] = true }

--- Resolve a `fragment=` value to its entrance CSS class, or nil when the
--- callout should not be a fragment.
--- @param value any
--- @return string|nil
local function fragment_class(value)
  if value == nil then
    return nil
  end
  local s = pandoc.utils.stringify(value)
  if s == "" or fragment_off[s] then
    return nil
  end
  return fragment_variants[s] or fragment_variants.burst
end

-- ============================================================================
-- STYLE / ATTRIBUTES
-- ============================================================================

--- Build the inline style attribute body from the position/size/rotate kwargs.
--- The rotation is emitted as the `--callout-rotate` custom property so the
--- comic theme owns the `transform` (letting fragment entrances settle at the
--- configured angle). Returns "" when no style applies.
--- @param kwargs table
--- @return string
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
    parts[#parts + 1] = "--callout-rotate:" .. angle
  end
  if #parts == 0 then
    return ""
  end
  return ' style="' .. table.concat(parts, ";") .. '"'
end

--- Assemble the shared callout attributes from the kwargs.
--- @param base_class string The callout's base class (e.g. "boom-callout").
--- @param colour_prefix string Prefix for the colour class (e.g. "boom").
--- @param default_colour string Fallback colour name.
--- @param kwargs table Shortcode kwargs.
--- @return string class_value The full space-separated class attribute value.
--- @return string style The ` style="..."` attribute string (or "").
--- @return string data The ` data-fragment-index="N"` attribute string (or "").
function M.attributes(base_class, colour_prefix, default_colour, kwargs)
  kwargs = kwargs or {}
  local colour = pick_colour(kwargs, default_colour)
  local classes = { base_class, colour_prefix .. "-" .. colour }
  local fragment = fragment_class(kwargs["fragment"])
  if fragment then
    classes[#classes + 1] = "fragment"
    classes[#classes + 1] = fragment
  end
  local style = build_style(kwargs)
  local index = safe_index(kwargs["index"])
  local data = index and (' data-fragment-index="' .. index .. '"') or ""
  return table.concat(classes, " "), style, data
end

return M
