-- Multibow internal "module" implementing convenience functions for sending
-- key presses to the USB host to which the Keybow device is connected to.

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

-- Our key ticker queue: its elements are keys and modifiers to press and
-- release, one after another, so that USB HID operations won't ever take too
-- long as to minimize tick jitter.
mb.keys = mb.tq:new()



-- Default delay between rapidly (repeated) key presses, can be overridden.
mb.KEY_DELAY_MS = mb.KEY_DELAY_MS or 100

-- Delay between key presses
function mb.delay()
    keybow.sleep(mb.KEY_DELAY_MS)
end

-- Sends a single key tap to the USB host, optionally with modifier keys, such
-- as SHIFT (keybow.LEFT_SHIFT), CTRL (keybow.LEFT_CTRL), et cetera. The "key"
-- parameter can be a string or a Keybow key code, such as keybow.HOME, et
-- cetera.
function mb.tap(key, ...)
    mb.tap_times(key, 1, ...)
end

-- Taps the same key multiple times, optionally with modifier keys; however,
-- for optimization, these modifiers are only pressed once before the tap
-- sequence, and only released once after all taps.
function mb.tap_times(key, times, ...)
    for modifier_argno = 1, select("#", ...) do
        local modifier = select(modifier_argno, ...)
        if modifier then keybow.set_modifier(modifier, keybow.KEY_DOWN) end
      end
      for _ = 1, times do
        keybow.tap_key(key)
        mb.delay()
    end
    for modifier_argno = 1, select("#", ...) do
        local modifier = select(modifier_argno, ...)
        if modifier then keybow.set_modifier(modifier, keybow.KEY_UP) end
      end
  end


-- Tick mappers execute a series of tick'ered function calls, passing in each
-- one of a sequence of things with each tick until done. So, this is like
-- array mappers, but this time they're broken into discrete ticks. And since
-- we sometimes need to do multiple ticked steps per element, our tick mappers
-- can also work on sequences of functions to be called for each element.
local KeyJobMapper = {}
KeyJobMapper.__index = KeyJobMapper
mb.KeyJobMapper = KeyJobMapper

-- Creates a new tick mapper that calls a function (or a sequence of
-- functions) on every element of an array, but only one call per tick.
--
-- luacheck: ignore 212/self
function KeyJobMapper:new(func, ...)
    -- Since we allow for sequences of functions, simply turn a single
    -- function given to us into a single-element sequence. Additionally, we
    -- need to handle the special test case where someone is giving us a
    -- function which in fact is a table (as "busted" does with spies and
    -- stubs).
    if type(func) == "function" or (type(func) == "table" and #func == 0) then
        func = {func}
    end
    local slf = {
        func=func, -- the function(s) to call for each element.
        fidx=1,
        flen=#func,
        elements={...}, -- the elements to map onto function calls.
        idx=1,
        len=#{...}
    }
    return setmetatable(slf, KeyJobMapper)
end

-- For each tick, process only the next element and next function in our list
-- until all functions for this element, and then all elements have been
-- processed. Only then indicate finish.
function KeyJobMapper:process()
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
        return self.idx <= self.len
    end
    -- There's always more to do, since there are more functions waiting to be called.
    return true
end

-- Convenience function mainly for TDD: adds a set of functions to be called
-- one after another in a ticked fashion; this allows testing KeyJobMapper
-- objects.
function mb.send_mapped(afterms, func, ...)
    mb.keys:add(
        KeyJobMapper:new(func, ...),
        afterms)
end

-- Adds a set of modifiers to be either pressed or released to the queue of
-- tick'ed key operations, so in each tick only one modifier will be pressed
-- or released. The state parameter should be either keybow.KEY_DOWN or
-- keybow.KEY_UP. The final variable args is/are the modifier(s) to be pressed
-- or released.
function mb.send_modifiers(afterms, state, ...)
    mb.keys:add(
        KeyJobMapper:new(
            function(mod) keybow.set_modifier(mod, state) end,
            ...),
        afterms)
end

-- Adds a sequence of key presses to the queue of tick'ed key operations,
-- optionally enclosed by modifier presses and releases.
function mb.send_keys(after, keys, ...)
    local modsno = #{...}
    -- First queue ticked modifier press(es) if necessary.
    if modsno > 0 then
        mb.send_modifiers(after, keybow.KEY_DOWN, ...)
        after = 0
    end
    -- For convenience, explode a single keys string parameter into its
    -- individual characters as an array.
    if type(keys) == "string" then
        local keysarr = {}
        for idx = 1, #keys do
            keysarr[idx] = keys:sub(idx, idx)
        end
        keys = keysarr
    end
    -- Queue the keys to tap in a sequence of ticks. Please note that we
    -- expect things to be already broken up at this point, as the tick mapper
    -- will dutyfully tap each element on each tick.
    mb.keys:add(
        KeyJobMapper:new({
                function(key) keybow.set_key(key, true) end,
                function(key) keybow.set_key(key, false) end
            },
            table.unpack(keys)),
        after)
    -- And finally queue to release the modifier keys if necessary.
    if modsno > 0 then
        mb.send_modifiers(0, keybow.KEY_UP, ...)
    end
end
