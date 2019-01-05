--[[
Copyright 2019 Harald Albrecht

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

mb = {} -- module

require "keybow"

mb.path = (...):match("^(.-)[^%/]+$")

require(mb.path .. "morekeys")
require(mb.path .. "routehandlers")


mb.brightness = 0.4
mb.keymaps = {}
mb.current_keymap = nil
mb.grab_keymap = nil


--
function mb.tap(keyno, key, ...)
  for modifier_argno = 1, select('#', ...) do
    local modifier = select(modifier_argno, ...)
    if modifier then; keybow.set_modifier(modifier, keybow.KEY_DOWN); end
  end
  keybow.tap_key(key)
  for modifier_argno = 1, select('#', ...) do
    local modifier = select(modifier_argno, ...)
    if modifier then; keybow.set_modifier(modifier, keybow.KEY_UP); end
  end
end


-- Registers a keymap (by name), so it can be easily activated later by its name.
-- Multiple keymaps can be registered. Keymaps can be either "primary" by
-- default, or permanent or secondary keymaps.
--
-- A primary keymap is any keymap without either a "permanent" or "secondary"
-- table element. Users can cycle through primary keymaps using the "shift"
-- permanent keyboard layout.
--
-- permanent keymaps (marked by table element "permanent=true") are always
-- active, thus they don't need to be activated.
--
-- Secondary keymaps (marked by table element "secondary=true") are intended
-- as SHIFT/modifier layers. As such the get ignored by cycling, but instead
-- need to be activated explicitly. The "shift" permanent keyboard layout
-- automates this.
--
-- If this is the first keymap getting registered, then it will also made
-- activated.
function mb.register_keymap(keymap)
  local name = keymap.name
  -- register
  mb.keymaps[name] = keymap
  -- ensure that first registered keymap also automatically gets activated
  -- (albeit the LEDs will only update later).
  if not (keymap.permanent or keymap.secondary) then
    mb.current_keymap = mb.current_keymap or keymap
  end
end


-- Returns the list of currently registered keymaps; this list is a table,
-- with its registered keymaps at indices 1, 2, ...
function mb.registered_keymaps()
  local keymaps = {}
  for name, keymap in pairs(mb.keymaps) do
    table.insert(keymaps, keymap)
  end
  return keymaps
end


-- Cycles through the available (primary) keymaps, ignoring secondary and
-- permanent keymaps. This is convenient for assigning primary keymap switching
-- using a key on the Keybow device itself.
function mb.cycle_primary_keymaps()
  local first_name
  local next = false
  local next_name
  for name, keymap in pairs(mb.keymaps) do
    if not (keymap.permanent or keymap.secondary) then
      -- Remembers the first "primary" keymap.
      first_name = first_name or name
      -- Notice if we just pass the current keymap and then make sure to pick
      -- up the following primary keymap.
      if keymap == mb.current_keymap then
        next = true
      elseif next then
        next_name = name
        next = false
      end
    end
  end
  next_name = next_name or first_name
  mb.activate_keymap(next_name)
end


-- Activates a specific keymap by name. Please note that it isn't necessary
-- to "activate" permanent keymaps at all (and thus this deed cannot be done).
function mb.activate_keymap(name)
  local keymap = mb.keymaps[name]
  if not keymap.permanent then
    mb.current_keymap = keymap
    mb.activate_leds()
  end
end


--
function mb.grab(name)
  mb.grab_keymap = mb.keymaps[name]
  mb.activate_leds()
end

function mb.ungrab()
  mb.grab_keymap = nil
  mb.activate_leds()
end


-- Sets the Keybow key LEDs maximum brightness, in the range [0.1..1].
function mb.set_brightness(brightness)
  if brightness < 0.1 then; brightness = 0.1; end
  if brightness > 1 then; brightness = 1; end
  mb.brightness = brightness
  mb.activate_leds()
end


-- Sets key LED to specific color, taking brightness into consideration.
-- The color is a triple (table) with the elements r, g, and b. Each color
-- component is in the range [0..1].
function mb.led(keyno, color)
  if color then
    local b = mb.brightness * 255
    keybow.set_pixel(keyno, color.r * b, color.g * b, color.b * b)
  else
    keybow.set_pixel(keyno, 0, 0, 0)
  end
end


-- Restores Keybow LEDs according to current keymap and the permanent keymaps.
function mb.activate_leds()
  keybow.clear_lights()
  -- if a grab is in place then it takes absolute priority
  if mb.grab_keymap then
    mb.activate_keymap_leds(mb.grab_keymap)
  else
    -- first update LEDs for the current keymap...
    if mb.current_keymap ~= nil then
      mb.activate_keymap_leds(mb.current_keymap)
    end
    -- ...then update LEDs from permanent keymap(s), as this ensures that
    -- the permanent keymaps take precedence.
    for name, keymap in pairs(mb.keymaps) do
      if keymap.permanent then
        mb.activate_keymap_leds(keymap)
      end
    end
  end
end


-- Helper function that iterates over all keymap elements but skipping non-key
-- bindings.
function mb.activate_keymap_leds(keymap)
  for keyno, keydef in pairs(keymap) do
    if type(keyno) == "number" and keydef.c then
      -- print((keymap.permanent and "permanent LED" or "LED") .. " " .. keyno)
      mb.led(keyno, keydef.c)
    end
  end
end


-- Disables the automatic Keybow lightshow and sets the key LED colors. This
-- is a well-known (hook) function that gets called by the Keybow firmware
-- after initialization immediately before waiting for key events.
function setup()
  -- Disables the automatic keybow lightshow and switches all key LEDs off
  -- because the LEDs might be in a random state after power on.
  keybow.auto_lights(false)
  keybow.clear_lights()
  mb.activate_leds()
end

return mb -- module
