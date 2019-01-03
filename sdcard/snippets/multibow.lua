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

require "keybow"

mb = {}
mb.path = (...):match("^(.-)[^%/]+$")

require(mb.path .. "morekeys")
require(mb.path .. "routehandlers")


mb.brightness = 0.4
mb.keymaps = {}
mb.permanent_keymaps = {}
mb.current_keymap_set = nil
mb.current_keymap_idx = 0


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


-- Registers a keymap by name (and optional) index. The name is simply used
-- for allowing multiple SHIFT (modifier) levels for the same keyboard layout.
-- The indices are then used to differentiate between different SHIFT/modifier
-- levels of the same keyboard layout.
--
-- Indices start at 0, this is the un-SHIFT-ed keymap for a layout.
--
-- If this is the first keymap getting registered, then it will also made
-- activated.
function mb.register_keymap(keymap, name, index)
  -- register
  local kms = mb.keymaps[name]
  kms = kms and kms or {} -- if name isn't known yet, create new keymap array for name
  local index = index and #kms or 0 -- appends keymap if index is nil
  kms[index] = keymap
  mb.keymaps[name] = kms
  -- ensure that first registered keymap also automatically gets activated
  -- (albeit the LEDs will only update later).
  if mb.current_keymap_set == nil then
    mb.current_keymap_set = kms
    mb.current_keymap_idx = index
  end
end


-- Cycles through the available (non-permanent) keymaps. When switching to
-- the next keymap, we will always activate the index 0 layout.
function mb.cycle_keymaps()
  local first_kms
  local first_name
  local next = false
  local next_kms
  local next_name
  for name, kms in pairs(mb.keymaps) do
    if first_kms == nil then
      first_kms = kms; first_name = name
    end
    if kms == mb.current_keymap_set then
      next = true
    elseif next then
      next_kms = kms; next_name = name
      next = false
    end
  end
  if next_kms == nil then
    next_kms = first_kms; next_name = first_name
  end
  mb.activate_keymap(next_name, 0)
end


-- Activates a specific keymap by name and index.
function mb.activate_keymap(name, index)
  print("activate_keymap", name, index)
  local kms = mb.keymaps[name]
  mb.current_keymap_set = kms
  mb.current_keymap_idx = index
  keybow.clear_lights()
  mb.activate_leds()
end


-- Registers a permanent keymap (as opposed to switchable keymaps). As their
-- name suggest, permanent keymaps are permanently active and have priority
-- over any "standard" activated keymap. As they are permanent, there is no
-- "index" sub-layout mechanism, but instead all permanent keymaps are always
-- active. If permanent keymaps define overlapping keys, then the result is
-- undefined.
function mb.register_permanent_keymap(keymap, name)
  -- register
  mb.permanent_keymaps[name] = keymap
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
  if color ~= nil then
    keybow.set_pixel(keyno,
      color.r * mb.brightness * 255, color.g * mb.brightness * 255, color.b * mb.brightness * 255)
  else
    keybow.set_pixel(keyno, 0, 0, 0)
  end
end


-- Restores Keybow LEDs according to current keymap and the permanent keymaps.
function mb.activate_leds()
  -- current keymap
  if mb.current_keymap_set ~= nil then
    for keyno, keydef in pairs(mb.current_keymap_set[mb.current_keymap_idx]) do
      print("LED", keyno)
      mb.led(keyno, keydef.c)
    end
  end
  -- permanent keymap(s)
  for name, pkm in pairs(mb.permanent_keymaps) do
    for keyno, keydef in pairs(pkm) do
      print("pLED", keyno)
      mb.led(keyno, keydef.c)
    end
  end
end


-- Disables the automatic Keybow lightshow and sets the key LED colors.
function setup()
  -- Disables the automatic keybow lightshow and switches all key LEDs off
  -- because the LEDs might be in a random state after power on.
  keybow.auto_lights(false)
  keybow.clear_lights()
  mb.activate_leds()
end
