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

local shift = {} -- module

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

function shift.grab(key)
  mb.grab("shift-shifted")
end

function shift.release(key)
  mb.ungrab()
end

function shift.cycle(key)
  mb.cycle_primary_keymaps()
end

function shift.brightness(key)
  local b = mb.brightness + 0.3
  if b > 1 then; b = 0.4; end
  mb.set_brightness(b)
end


-- define and register keymaps

shift.keymap = {
  name="shift",
  permanent=true,
  [11] = {c={r=1, g=1, b=1}, press=shift.grab, release=shift.release},
}
shift.keymap_shifted = {
  name="shift-shifted",
  secondary=true,
  [11] = {c={r=1, g=1, b=1}, press=shift.grab, release=shift.release},

  [8] = {c={r=0, g=1, b=1}, press=shift.cycle},
  [5] = {c={r=0.5, g=0.5, b=0.5}, press=shift.brightness}
}

mb.register_keymap(shift.keymap)
mb.register_keymap(shift.keymap_shifted)

return shift -- module
