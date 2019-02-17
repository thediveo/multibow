-- Multibow internal "module" implementing a "ticking" (key) queue.

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

local tq = {}
tq.__index = tq

-- Creates a new ticking queue. All elements are stored in a singly linked
-- list, with only the first (foremost) list element being active and
-- processed when ticking along. Only after the first element has finished its
-- processing it gets removed and the next element moves into first position,
-- getting processed next.
--
-- luacheck: ignore 212/self
function tq:new()
    return setmetatable({
        head=nil,
        tail=nil,
        at=nil,
        now=0
    }, tq)
end

-- Adds another element to this ticking queue, waiting to be processed when
-- its turn finally has come. Additionally, start of processing for this
-- element can be delayed if necessary by the given timespan.
function tq:add(element, afterms)
    element.afterms = afterms or 0
    -- Add the new element to the tail of this list, and move the tail
    -- accordingly to point to our new trailing element.
    if self.tail then
        self.tail.next = element
    end
    element.next = nil
    self.tail = element
    -- If queue has been empty, then our new element becomes the head of the
    -- list.
    if not self.head then
        self.head = element
        self.at = self.now + self.head.afterms
    end
end

-- Processes the head element of this ticking queue for another tick. If the
-- head element then signals that it has finished, then the next element in
-- queue will be processed in the next turn.
function tq:process(now)
    self.now = now
    if self.head == nil then return end
    -- Did we already passed the time where the head element in this
    -- queue is supposed to become active?
    if now < self.at then return end
    if self.head:process(now) then return end
    -- The foremost element finished its processing, so let's move on to the
    -- next element in our list ... if there is any. It will start its
    -- processing with the next tick; we're just setting up things here for
    -- this next round.
    self.head = self.head.next
    if self.head then
        self.at = self.now + self.head.afterms
    end
end

return tq -- module
