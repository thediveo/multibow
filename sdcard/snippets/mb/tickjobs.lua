-- Multibow internal "module" implementing background jobs to be run on (more
-- or less) regular ticks. In particular, this is used to send USB keystrokes
-- to the USB host in the background.

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


-- Multibow's tick jobs are processed in the "background", but synchronously
-- with each tick() of the Keybow firmware. Normally, tick()s will happen
-- every 1ms, but might get skipped in case some Keybow Lua script/function
-- run for a longer time, delaying the next tick.
--
-- 1. Tick jobs are always run one after another, but never in parallel; thus,
--    only at most one tick job can be active at any given time. In this
--    sense, repeated and hierarchical tick jobs are also considered to be in
--    sequence and never to be parallel.
--
-- 2. A single tick job can run for as many ticks it needs to carry out its
--    task. Multibow will call the active's process() method for each tick
--    until it signals defeat, erm, completion by returning a (delay) value of
--    <0. When process() returns a value >=0, then this is the amount of ms
--    (ticks) to delay the call to process() on the next time. That is, 0
--    means "on the next tick", 1 means "on the next but one tick".
--
-- 3. The start of a tick job can be delayed by a certain amount of ms
--    (ticks), if needed.
--
-- 4. Tick jobs commonly define a constructor called "new(...)" to create new
--    tick jobs of a particular type.
--
-- 5. Multibow's tick job architecture expects tick jobs to always provide
--    these two methods for correct operation: process() and reset(). As
--    mentioned above, process() gets called so that a tick job can carry out
--    its next slice of task until it's done. And reset() resets a tick job to
--    its initial state so that it can be repeated.
--
-- 6. Tick jobs can carry out subjobs, but that's hidden to Multibow and just
--    the internal business of such tick jobs. However, such subjobs need to
--    be stored in a "tickjob" field of a tick job; this is necessary so the
--    chaining operators can do their dirty work correctly.


-- Tick job mappers execute a series of tick'ered function calls, passing the
-- function(s) each one of a sequence of things with each tick until done. So,
-- tick job mappers are like array mappers, but this time they're broken into
-- discrete ticks. And since we sometimes need to do multiple ticked steps per
-- element, our tick job mappers can also work on sequences of functions to be
-- called for each element.
local TickJobMapper = {}
TickJobMapper.__index = TickJobMapper
mb.TickJobMapper = TickJobMapper

-- Creates a new tick job mapper that calls a function (or a sequence of
-- functions when you pass in an array of functions) on every element
-- specified in the new() constructor.
-- * The "func" argument might be either a single function or an array (table)
--   of functions.
-- * The "..." remaining arguments specify all the elements to iterate over.
function TickJobMapper:new(func, ...) -- luacheck: ignore 212/self
    -- Since we allow for sequences of functions, simply turn a single
    -- function given to us into a single-element sequence. Additionally, we
    -- need to handle the special test case where someone is giving us a
    -- function which in fact is a table (as "busted" does with spies and
    -- stubs). Bottom line: we would need much more room here to explain the
    -- what than to simply do our thing. Sigh.
    if type(func) == "function" or (type(func) == "table" and #func == 0) then
        func = {func}
    end
    local slf = setmetatable({
        func=func, -- the function(s) to call for each element.
        flen=#func,
        elements={...}, -- the elements to map onto function calls.
        len=#{...}
    }, TickJobMapper)
    slf:reset()
    return slf
end

-- Resets a tick mapper so it can be repeated (using another tick job
-- repeater).
function TickJobMapper:reset()
    self.fidx = 1
    self.idx = 1
end

-- For each tick, process only the next element and next function in our list
-- until all functions for this element, and then all elements have been
-- processed. Only then declare finish by returning -1 as the "done"
-- indication. Related, return 0 if there is still work to be done on the next
-- round, or a positive "afterms" value indicating to call back only later.
function TickJobMapper:process()
    -- Don't wonder why we shield this, but this way we also correctly handle
    -- the border case of an empty list of elements to map without crashing.
    if self.idx <= self.len then
        self.func[self.fidx](self.elements[self.idx])
    end
    -- Update function index to next function in sequence, and only when we
    -- have run all functions, then proceed with the next element.
    self.fidx = self.fidx + 1
    if self.fidx > self.flen then
        self.fidx = 1
        -- Update index to next element and indicate back whether we'll need a
        -- further round in the future.
        self.idx = self.idx + 1
        return self.idx <= self.len and 0 or -1
    end
    -- There's always more to do, since there are more functions waiting to be
    -- called; and we want to process the next function with the next tick.
    return 0
end


-- Tick job repeaters allow repeating other tick jobs, including other tick
-- job repeaters; that is, we can repeat repeaters.
local TickJobRepeater = {}
TickJobRepeater.__index = TickJobRepeater
mb.TickJobRepeater = TickJobRepeater

-- Creates a new tick job repeater that repeats another tick job.
-- * tickjob: another tick job (object) to be repeated. Don't add that tick
--   job to Multibow's tick job queue, only reference it here.
-- * times: number of times to repeat the other tick job.
-- * pause: pause in ms inbetween consecutive runs of the other tick job; this
--   is different from the standard initial delay before starting any tick
--   job, as it only happens inbetween repeated tick jobs.
function TickJobRepeater:new(tickjob, times, pause) -- luacheck: ignore 212/self
    pause = pause or 0
    local slf = setmetatable({
        tickjob=tickjob,
        times=times,
        pause=pause
    }, TickJobRepeater)
    slf:reset()
    return slf
end

-- Resets a tick job repeater, so repeaters can even repeat repeaters.
-- (ARGH!!!)
function TickJobRepeater:reset()
    self.round = 1
end

-- Processes a tick job repeater: this processes the tickjob to be repeated
-- until it signals that it is done, then we check if we still need to repeat
-- until we've repeated as many times as originally demanded.
function TickJobRepeater:process()
    local afterms = self.tickjob:process()
    if afterms >= 0 then return afterms end
    -- Start the next round ... or are we done now? Please note that the next
    -- round might be delayed if so required in order to give the applications
    -- on the USB host system some time to process the burst of key events.
    -- Well, that's not meant with respect to USB and USB host, but instead
    -- the applications working on key input.
    self.round = self.round + 1
    -- Always reset, so repeater cascades work ... greetings to M.C.E.
    self.tickjob:reset()
    return self.round <= self.times and self.pause or -1
end


-- Enclose another tick job in "before" and "after" function mappers.
local TickJobEncloser = {}
TickJobEncloser.__index = TickJobEncloser
mb.TickJobEncloser = TickJobEncloser

-- Creates a new tick job enclosing another tick job and calling a first
-- function on a set of elements before the other tick job, and a second
-- function on a set of elements after the tick job. Nope, this still hasn't
-- yet reached the unreadability of intellectual poverty claims.
function TickJobEncloser:new(tickjob, beforefunc, afterfunc, ...) -- luacheck: ignore 212/self
    local slf = setmetatable({
        tickjob=tickjob,
        beforefunc=beforefunc,
        afterfunc=afterfunc,
        elements={...},
        len=#{...}
    }, TickJobEncloser)
    slf:reset()
    return slf
end

-- Resets a tick job encloser to its initial state, so that it can be properly
-- repeated.
function TickJobEncloser:reset()
    self.phase = 1
    self.idx = 1
end

-- Processes a tick job encloser in three phases:
-- 1. call the before function on each element specified when creating the
--    tick job encloser. For instance, this might press modifier keys.
-- 2. call the sub tick job until it's done.
-- 3. call the after function on each element specified when creating the tick
--    job encloser. For instance, thig might release the modifier keys that
--    there presses just before the sub tick job.
function TickJobEncloser:process()
    -- Phase I: map the "before" function onto each element.
    if self.phase == 1 then
        if self.idx <= self.len then
            self.beforefunc(self.elements[self.idx])
            self.idx = self.idx + 1
            return 0
        end
        self.phase = 2 -- immediately proceed to next phase.
    end
    -- Phase II: process the sub tickjob until it signals that it's done.
    if self.phase == 2 then
        local afterms = self.tickjob:process()
        if afterms >= 0 then return afterms end
        self.phase = 3 -- proceed to final phase with next tick.
        self.idx = 1
        return 0
    end
    -- Phase III: map the "after" function onto each element.
    if self.idx <= self.len then
        self.afterfunc(self.elements[self.idx])
        self.idx = self.idx + 1
    end
    return self.idx <= self.len and 0 or -1
end

-- A sequence of tick jobs.
local TickJobSequencer = {}
TickJobSequencer.__index = TickJobSequencer
mb.TickJobSequencer = TickJobSequencer

function TickJobSequencer:new() -- luacheck: ignore 212/self
    local slf = setmetatable({
        tickjobs = {}
    }, TickJobSequencer)
    slf:reset()
    return slf
end

function TickJobSequencer:reset()
    self.idx = 0 -- note an optional wait phase for the first sub job.
    self.jobs = #self.tickjobs -- keep number of subjobs
    for _, job in ipairs(self.tickjobs) do
        job:reset()
    end
end

function TickJobSequencer:add(tickjob)
    tickjob.afterms = tickjob.afterms or 0
    table.insert(self.tickjobs, tickjob)
    self.jobs = #self.tickjobs
end

function TickJobSequencer:process()
    if self.idx == 0 then
        self.idx = 1
        if self.jobs > 0 and self.tickjobs[1].afterms > 0 then
            -- delay the first sub process according to its configuration.
            return self.tickjobs[1].afterms
        end
        -- fall through to immediately process first sub job.
    end
    if self.idx <= self.jobs then
        local afterms = self.tickjobs[self.idx]:process()
        if afterms >= 0 then return afterms end
        self.idx = self.idx + 1
    end
    -- Please note that each sub job in the sequence might have its own
    -- initial afterms delay.
    return self.idx <= self.jobs and self.tickjobs[self.idx].afterms or -1
end

