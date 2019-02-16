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
-- array mappers, but this time they're broken into discrete ticks.
local TickMapper = {}
TickMapper.__index = TickMapper
mb.TickMapper = TickMapper

-- Creates a new tick mapper that calls a function on every element of an
-- array, but only one call per tick.
--
-- luacheck: ignore 212/self
function TickMapper:new(func, ...)
    local slf = {
        func=func, -- the function to call for each element.
        elements={...}, -- the elements to map onto function calls.
        idx=1,
        len=#{...}
    }
    return setmetatable(slf, TickMapper)
end

-- For each tick, process only the next element in our list until all elements
-- have been processed. Then indicate finish.
function TickMapper:process()
    -- Don't wonder why we shield this, but this way we also correctly handle
    -- the border case of an empty list of elements to map without crashing.
    if self.idx <= self.len then
        self.func(self.elements[self.idx])
    end
    -- Update index to next element and indicate back whether we'll need a
    -- further round in the future.
    self.idx = self.idx + 1
    return self.idx <= self.len
end

-- Adds a set of modifiers to be either pressed or released to the queue of
-- tick'ed key operations, so in each tick only one modifier will be pressed
-- or released. The state parameter should be either keybow.KEY_DOWN or
-- keybow.KEY_UP. The final variable args is/are the modifier(s) to be pressed
-- or released.
function mb.addmodifiers(after, state, ...)
    mb.addkeyticker(
        TickMapper:new(
            function(mod) keybow.set_modifier(mod, state) end,
            ...
        ),
        after)
end

-- Adds a sequence of key presses to the queue of tick'ed key operations,
-- optionally enclosed by modifier presses and releases.
function mb.addkeys(after, keys, ...)
    local modsno = #{...}
    -- First queue ticked modifier press(es) if necessary.
    if modsno > 0 then
        mb.addmodifiers(after, keybow.KEY_DOWN, ...)
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
    -- Queue the keys to tap in a sequence of ticks.
    mb.addkeyticker(
        TickMapper:new(
            function(key) keybow.tap_key(key) end,
            table.unpack(keys)
        ),
        after)
    -- And finally queue to release the modifier keys if necessary.
    if modsno > 0 then
        mb.addmodifiers(0, keybow.KEY_UP, ...)
    end
end

-- All key tickers are handled in a (singly linked) list, as only the first
-- key ticker can be active and getting processed. Only after the first one
-- has finished, it is removed, and the next (now new) key ticker gets
-- processed. And so on...
local firstkey = nil
local lastkey = nil
-- Key tickers can be initially delayed as necessary.
local keyafter = 0

-- Adds another asynchronous USB HID key operation at the end of the key
-- queue, waiting to be processed piecemeal-wise tick by tick.
function mb.addkeyticker(keyop, afterms)
    keyop.afterms = afterms or 0
    if lastkey then
        lastkey.next = keyop
    end
    keyop.next = nil
    lastkey = keyop
    if not firstkey then
        -- Queue was empty before, so we need to kick it off...
        firstkey = keyop
        keyafter = mb.now + keyop.afterms
    end
end

-- Key tick(ing) handler responsible to work on the current key operation as
-- well as on the asynchronous key operations queue tick by tick. Since key
-- operations are always in sequence as added, there is no point in using a
-- (min) priority queue here. Instead, we roll our own very basic and
-- low-profile single-linked list.
function mb.tickkey(t)
    -- something in the queue (still) to be processed?
    if firstkey and t >= keyafter then
        if not firstkey:process() then
            -- as the current key operation has finished, so prepare the next
            -- key operation for the next round, optionally delaying it the
            -- span requested.
            firstkey = firstkey.next
            if firstkey then
                keyafter = mb.now + firstkey.afterms
            end
        end
    end
end
