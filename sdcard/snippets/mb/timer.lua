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

-- Private Timer class stores information about a specific timer and allows
-- applications to later cancel them.
local Timer = {}
Timer.__index = Timer

-- Cancels a timer, regardless of whether it has already been triggered, or
-- not.
function Timer:cancel()
    if self:isarmed() then
        -- Don't forget to remove ourselves if we were still armed.
        mb.timers:delete(self.at, self.timerf)
        self.at = math.mininteger
    end
end

-- Calls the timer's user function with its user arguments and then disables
-- this timer.
function Timer:trigger()
    if self.at >= 0 then
        self.at = math.mininteger
        if self.timerf then
            self.timerf(table.unpack(self.targs))
        end
    end
end

-- Returns true if the timer is still running and hasn't triggered yet;
-- otherwise, it returns false.
function Timer:isarmed()
    return self.at >= 0
end

-- Activates the given timer user function after a certain amount of time has
-- passed. Returns a timer object that can be used to cancel the timer.
function mb.after(afterms, timerf, ...)
    local at = mb.now + (afterms < 0 and 0 or afterms)
    local tim = {
        at = at,
        timerf = timerf,
        targs = {...}
    }
    setmetatable(tim, Timer)
    mb.timers:add(at, tim)
    return tim
end

-- Triggers a timer every specified ms until it finally gets canceled. Please
-- note that the trigger will trigger for the first time only after "everyms",
-- but not immediately.
function mb.every(everyms, timerf, ...)
    local shim = {
        everyms = everyms < 1 and 1 or everyms,
        timerf = timerf,
        targs = {...}
    }
    -- add an alarm after the first period which then triggers our shim
    -- function; only the shim function will then trigger the user function,
    -- and also readd the (shim) alarm so that the cycle will repeat ad
    -- nauseam.
    local tim = mb.after(
        everyms,
        function(shim) -- luacheck: ignore 431/shim
            if shim.timerf then
                shim.timerf(table.unpack(shim.targs))
            end
            shim.tim.at = mb.now + everyms
            mb.timers:add(shim.tim.at, shim.tim)
        end,
        shim)
    shim.tim = tim
    return tim
end

-- Tick gets called by the Keybow "firmware" every 1ms (or so). If any timers
-- have gone off by now, then call their timer user functions. Keybow's tick
-- ms counter has its epoch set when the Keybow Lua scripting started (so it's
-- not a *nix timestamp or such).
function tick(t)
    mb.now = t
    while true do
        local next, tim = mb.timers:peek()
        if next == nil or t < next then
            break
        end
        mb.timers:remove()
        tim:trigger()
    end
end
