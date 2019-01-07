-- A permanent "SHIFT" keymap for cycling keymaps and LED brightness control.

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

-- allow users to set their own configuration before req'ing this
-- module, in order to control the key layout. For defaults, please see
-- below.
local shift = _G.shift or {} -- module

local mb = require "snippets/multibow"

--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

              ┋┋
╔════╗  ╔╌╌╌╌╗  ╔╌╌╌╌╗  ┌╌╌╌╌┐
║ 11 ║  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
╚════╝  ╚╌╌╌╌╝  ╚╌╌╌╌╝  └╌╌╌╌┘
SHIFT   →LAYOUT  🔆BRIGHT
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘


]]--


-- Default hardware key to function assignments, can be overriden by users
shift.KEY_SHIFT = shift.KEY_SHIFT or 11
shift.KEY_LAYOUT = shift.KEY_LAYOUT or 8
shift.KEY_BRIGHTNESS = shift.KEY_BRIGHTNESS or 5

shift.BRIGHTNESS_LEVELS = shift.BRIGHTNESS_LEVELS or { 70, 100, 40 } 


-- Internal flag for detecting SHIFT press-release sequences without any SHIFTed
-- function.
local shift_only = false
local grabbed_key_count = 0

-- Activates the first brightness level...
shift.brightnesses = table.pack(table.unpack(shift.BRIGHTNESS_LEVELS))
mb.cycle_brightness(shift.brightnesses)

-- Switches to the next SHIFT layer within the currently active keyboard layout.
-- SHIFT layer(s) are wired up as a circular list of keymaps, linked using their
-- "shift_to" elements.
function shift.shift_secondary_keymap()
    local keymap = mb.current_keymap
    if keymap and keymap.shift_to then
        mb.activate_keymap(keymap.shift_to.name)
    end
end

-- Remember how many grabbed keys are pressed, so we won't ungrab later until
-- all keys have been released.
function shift.any_press(keyno)
    grabbed_key_count = grabbed_key_count + 1
end

-- Only ungrab after last key has been released
function shift.any_release(keyno)
    if grabbed_key_count > 0 then
        grabbed_key_count = grabbed_key_count - 1
        if grabbed_key_count == 0 then
            -- Ungrabs after last key released.
            mb.ungrab()
            -- And switches between keymaps within the same set.
            if shift_only then
                shift.shift_secondary_keymap()
            end
        end
    end
end

-- SHIFT press: switches into grabbed SHIFT mode, activating the in-SHIFT keys
-- for brightness change, keymap cycling, et cetera.
function shift.shift(key)
    grabbed_keys = 1 -- includes myself; this is necessary as the grab "any"
                     -- handler will not register the SHIFT press, because it
                     -- wasn't grabbed yet.
    shift_only = true
    shift.any_press(key)
    mb.grab(shift.keymap_shifted.name)
end

-- Cycles to the next primary keyboard layout (keymap)
function shift.cycle(key)
    shift_only = false
    mb.cycle_primary_keymaps()
end

-- Changes the Keybow LED brightness, by cycling through different brightness
-- levels
function shift.brightness(key)
    shift_only = false
    mb.cycle_brightness(shift.brightnesses)
    mb.led(key, shift.next_brightness_color())
end

-- Returns the color for the BRIGHTNESS key LED: this is the next brightness
-- level in the sequence of brightness levels as a color of gray/white.
function shift.next_brightness_color()
    local br = shift.brightnesses[1]
    br = br > 1.0 and br / 100 or br
    return { r=br, g=br, b=br }
end

-- define and register our keymaps: the permanent SHIFT key-only keymap, as well
-- as a temporary grabbing keymap while the SHIFT key is being pressed and held.
shift.keymap = {
  name="shift",
  permanent=true,
  [shift.KEY_SHIFT] = {c={r=1, g=1, b=1}, press=shift.shift},
}
shift.keymap_shifted = {
  name="shift-shifted",
  secondary=true,
  [-1] = {press=shift.any_press, release=shift.any_release},
  [shift.KEY_SHIFT] = {c={r=1, g=1, b=1}},

  [shift.KEY_LAYOUT] = {c={r=0, g=1, b=1}, press=shift.cycle, release=shift.release_other},
  [shift.KEY_BRIGHTNESS] = {c=shift.next_brightness_color, press=shift.brightness, release=shift.release_other}
}
mb.register_keymap(shift.keymap)
mb.register_keymap(shift.keymap_shifted)


return shift -- module
