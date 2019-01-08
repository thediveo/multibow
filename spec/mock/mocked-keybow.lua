-- Mocks some parts of the Keybow Lua module during unit tests, so we can run
-- the tests outside the Keybow firmware on a standard (full-blown) Lua host
-- system.

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

local busted=require("busted")
local sock=require("socket")

require "keybow"
-- luacheck: globals keybow.no_delay
keybow.no_delay = keybow.no_delay or true

busted.stub(keybow, "auto_lights")
busted.stub(keybow, "clear_lights")
busted.stub(keybow, "load_pattern")
busted.stub(keybow, "set_pixel")
busted.stub(keybow, "set_key")
busted.stub(keybow, "set_modifier")
busted.stub(keybow, "tap_key")

-- luacheck: globals keybow.sleep
function keybow.sleep(ms)
    if not keybow.no_delay then
        sock.sleep(ms / 1000)
    end
end

-- luacheck: globals keybow.usleep
function keybow.usleep(us)
    keybow.sleep(us / 1000)
end

return keybow -- adhere to Lua's (new) module rules
