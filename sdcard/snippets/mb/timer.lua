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

-- luacheck: globals mb tick

-- Our timer queue ... is nothing more than a priority queue.
mb.timers = mb.pq:new()
mb.now = 0

-- Activates the given timer user function after a certain amount of time has
-- passed.
function mb.after(afterms, timerf)
    afterms = afterms < 0 and 0 or afterms
    mb.timers:add(mb.now + afterms, timerf)
end

-- Tick gets called by the Keybow "firmware" every 1ms (or so). If any timers
-- have gone off by now, then call their timer user functions. Keybow's tick
-- ms counter has its epoch set when the Keybow Lua scripting started (so it's
-- not a *nix timestamp or such).
function tick(t)
    mb.now = t
    while true do
        local next, timerf = mb.timers:peek()
        if next == nil or t < next then
            break
        end
        mb.timers:remove()
        timerf(t)
    end
end
