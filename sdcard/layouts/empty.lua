-- An empty Multibow Keybow layout. Useful for "switching off" the keyboard,

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

mb.register_keymap({}, "empty")
