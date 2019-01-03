-- A permanent SHIFT layout toggler

require "snippets/multibow"

--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

            ┋┋
┌────┐ ┌────┐ ┌────┐ ┌────┐
│ 11 │ │  8 │ │  5 │ │  2 │
└────┘ └────┘ └────┘ └────┘
┌────┐ ┌────┐ ┌────┐ ┌────┐
│ 10 │ │  7 │ │  4 │ │  1 │
└────┘ └────┘ └────┘ └────┘
┌────┐ ┌────┐ ┌────┐ ┌────┐
│  9 │ │  6 │ │  3 │ │  0 │
└────┘ └────┘ └────┘ └────┘

]]--

shift = {}

function shift.cycle(key)
  print("permanent SHIFT")
  mb.cycle_keymaps()
end

function shift.brightness(key)
  local b = mb.brightness + 0.3
  if b > 1 then; b = 0.4; end
  mb.set_brightness(b)
end

mb.register_permanent_keymap({
  [11] = {c={r=1, g=1, b=1}, h=shift.cycle},
  [8] = {c={r=0.5, g=0.5, b=0.5}, h=shift.brightness}
}, "shift")
