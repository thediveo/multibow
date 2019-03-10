-- "Multibow" is a Lua module for Pimoroni's Keybow firmware that offers and
-- manages multiple keyboard layouts.

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

-- luacheck: globals mb
mb = mb or {} -- module

require "keybow"

-- Pulls in the individual modules that make up Multibow.
mb.path = (...):match("^(.-)[^%/]+$")

mb.pq = require(mb.path .. "mb/prioqueue")
mb.tickqueue = require(mb.path .. "mb/tickqueue")
require(mb.path .. "mb/ticker")
require(mb.path .. "mb/timer")
require(mb.path .. "mb/morekeys")
require(mb.path .. "mb/keymaps")
require(mb.path .. "mb/tickjobs")
require(mb.path .. "mb/keys")
require(mb.path .. "mb/routehandlers")
require(mb.path .. "mb/leds")


-- Disables the automatic Keybow lightshow and sets the key LED colors. This
-- is a well-known (hook) function that gets called by the Keybow firmware
-- after initialization immediately before waiting for key events.
-- luacheck: globals setup
function setup()
  -- Disables the automatic keybow lightshow and switches all key LEDs off
  -- because the LEDs might be in a random state after power on.
  keybow.auto_lights(false)
  keybow.clear_lights()
  mb.activate_leds()
end


return mb -- module
