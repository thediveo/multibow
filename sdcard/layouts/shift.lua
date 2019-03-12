-- A permanent "SHIFT" Multibow keymap layout for cycling keymaps, LED
-- brightness control, and adding SHIFT layers to other Multibow keyboard
-- (multi) layouts.

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

-- luacheck: ignore 614
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


-- Default minimum time in ms to press and hold SHIFT in order to trigger the
-- special layout for changing layouts and the LED brightness.
shift.HOLD = shift.HOLD or 500

-- Default hardware key to function assignments, can be overriden by users
shift.KEY_SHIFT = shift.KEY_SHIFT or 11
shift.KEY_LAYOUT = shift.KEY_LAYOUT or 8
shift.KEY_BRIGHTNESS = shift.KEY_BRIGHTNESS or 5

-- (Default) key colors for SHIFT key in normal and special mode.
shift.COLOR_SHIFT = shift.COLOR_SHIFT or {r=1, g=1, b=1}
shift.COLOR_SPECIAL = shift.COLOR_SPECIAL or {r=0, g=0, b=1}

shift.BRIGHTNESS_LEVELS = shift.BRIGHTNESS_LEVELS or { 70, 100, 40 }


-- The pending one-shot alarm object required to detect pressing and holding
-- the SHIFT for longer than its threshold. We need this alarm object in case
-- we need to cancel it before it fires.
local alarm = nil
-- Drive the glowing SHIFT key when in special mode...
local glower = nil
local t0 = 0
local every = 10 -- ms
local period = 1000 -- ms

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

-- SHIFT key press:
-- * while in grab, ungrabs; that is, deactivates the special SHIFT overlay.
--   And switches off the annoyingly glowing SHIFT key ;)
-- * when not in grab, then starts the alarm for detecting a long press.
function shift.shiftpress()
    if mb.grabber() == shift.keymap_shifted then
        if alarm then alarm:cancel() end
        alarm = nil
        if glower then glower:cancel() end
        glower = nil
        mb.ungrab()
    else
        alarm = mb.after(
            shift.HOLD,
            function()
                -- when SHIFT has been hold long enough, then activate the
                -- special functions and start glowing the SHIFT key.
                mb.grab(shift.keymap_shifted.name)
                alarm = nil
                glower = mb.every(every, shift.glow)
                t0 = mb.now
            end)
    end
end

-- SHIFT key release:
-- * while in grab: don't care.
-- * when not in grab: cancel any outstanding long-press detection alarm if it
--   hasn't already been fired and deleted and cycle switch to the SHIFT layer
--   of the currently active layout.
function shift.shiftrel()
    if mb.grabber() ~= shift.keymap_shifted then
        if alarm then
            alarm:cancel()
            alarm = nil
            shift.shift_secondary_keymap()
        end
    end
end

-- Glows the SHIFT key while the special SHIFT functions are active (and we're
-- in grab mode).
function shift.glow()
    local brightness = 0.2 + 0.3 * (1 + math.cos((mb.now - t0)/period*math.pi))
    mb.led(shift.KEY_SHIFT, {
        r=brightness * shift.COLOR_SPECIAL.r,
        g=brightness * shift.COLOR_SPECIAL.g,
        b=brightness * shift.COLOR_SPECIAL.b
    })
end

-- Cycles to the next primary keyboard layout (keymap)
function shift.cycle(_)
    mb.cycle_primary_keymaps()
end

-- Changes the Keybow LED brightness, by cycling through different brightness
-- levels
function shift.brightness(key)
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
  [shift.KEY_SHIFT] = {c=shift.COLOR_SHIFT, press=shift.shiftpress, release=shift.shiftrel},
}
shift.keymap_shifted = {
  name="shift-shifted",
  secondary=true,
  [shift.KEY_SHIFT] = {c=shift.COLOR_SPECIAL, press=shift.shiftpress, release=shift.shiftrel},

  [shift.KEY_LAYOUT] = {c={r=0, g=1, b=1}, press=shift.cycle},
  [shift.KEY_BRIGHTNESS] = {c=shift.next_brightness_color, press=shift.brightness}
}
mb.register_keymap(shift.keymap)
mb.register_keymap(shift.keymap_shifted)


return shift -- module
