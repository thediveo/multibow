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


-- Internal flag for detecting SHIFT press-release sequences without any SHIFTed
-- function.
local shift_only = false
local in_shift = false
local other_key = false


-- Switch to the next SHIFT layer within the currently active keyboard layout.
-- SHIFT layer(s) are wired up as a circular list of keymaps, linked using their
-- "shift_to" elements.
function shift.shift_secondary_keymap()
    local keymap = mb.current_keymap
    if keymap and keymap.shift_to then
        mb.activate_keymap(keymap.shift_to.name)
    end
end


function shift.release_other()
    other_key = false
    if not in_shift then
        mb.ungrab()
    end
end


-- SHIFT press: switches into grabbed SHIFT mode, activating brightness change,
-- keymap cycling, et cetera.
function shift.grab(key)
    mb.grab("shift-shifted")
    in_shift = true
    other_key = false -- play safe.
    shift_only = true
end


-- SHIFT release: leaves (grabbed) SHIFT mode, but only if there is no other
-- (bound) key currently being held.
function shift.release(key)
    in_shift = false
    if not other_key then
        mb.ungrab()
    end
    if shift_only then
        shift.shift_secondary_keymap()
    end
end


-- Cycles to the next primary keyboard layout (keymap)
function shift.cycle(key)
    other_key = true
    shift_only = false
    mb.cycle_primary_keymaps()
end


-- Changes the Keybow LED brightness, by cycling through different brightness
-- levels
function shift.brightness(key)
    other_key = true
    shift_only = false
    local b = mb.brightness + 0.3
    if b > 1 then; b = 0.4; end
    mb.set_brightness(b)
end


-- define and register our keymaps: the permanent SHIFT key-only keymap, as well
-- as a temporary grabbing keymap while the SHIFT key is being pressed and held.
shift.keymap = {
  name="shift",
  permanent=true,
  [shift.KEY_SHIFT] = {c={r=1, g=1, b=1}, press=shift.grab, release=shift.release},
}
shift.keymap_shifted = {
  name="shift-shifted",
  secondary=true,
  [shift.KEY_SHIFT] = {c={r=1, g=1, b=1}, press=shift.grab, release=shift.release},

  [shift.KEY_LAYOUT] = {c={r=0, g=1, b=1}, press=shift.cycle, release=shift.release_other},
  [shift.KEY_BRIGHTNESS] = {c={r=0.5, g=0.5, b=0.5}, press=shift.brightness, release=shift.release_other}
}
mb.register_keymap(shift.keymap)
mb.register_keymap(shift.keymap_shifted)


return shift -- module
