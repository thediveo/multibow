-- A demonstration-only layout glowing a single LED which constantly modulates
-- its intensity as long as this keybow layout is active. Other than for
-- demonstration, probably not of too much use, except as maybe some kind of
-- calm-down device...

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

local glow = {} -- module

local mb = require("snippets/multibow")

--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

              ┋┋
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 11 ┊  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

]]--

local every = 10 -- ms; how often to update the LED.
local period = 1000 -- ms; length of intensity modulation period. 

local timer = nil -- stores the timer object as long as this layout is active.
local t = 0

-- When this keybow layout gets activated, start the cyclic timer to update
-- the LED.
function glow.activate()
    t = 0
    timer = mb.every(every, glow.led)
end

-- When the layout gets deactivated, make sure to kill the cyclic timer,
-- because otherwise the LED would continue glowing to infinity or end of
-- power.
function glow.deactivate()
    timer:cancel()
    timer = nil
end

-- Updates the LED brightness, modulating the intensity using a cosinus wave
-- with the given period length. The intensity function is independent of how
-- often the updates get triggered; but the results get jerky if there are too
-- few updates per second.
function glow.led()
    t = t + every
    local brightness = 0.5 * (1 - math.cos(t/1000*math.pi))
    mb.led(0, {r=brightness, g=brightness, b=brightness})
end

-- The "glow" keymap layout, not there really is much here to see, except for
-- the "magic" activate= and deactivate= configurations which specify
-- functions to be called by Multibow when this keymap gets activated or
-- deactivated. We need this for housekeeping purposes, especially for the
-- cyclic LED update function.
glow.keymap = {
    name="glow",
    activate=glow.activate,
    deactivate=glow.deactivate
}
mb.register_keymap(glow.keymap)

return glow -- module
