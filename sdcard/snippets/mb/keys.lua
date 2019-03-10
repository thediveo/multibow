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
mb.tq = mb.tickqueue:new()



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


  --[[
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
function mb.send_keys_repeatedly(after, times, pause, keys, ...)
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

function mb.send_keys(after, keys, ...)
    mb.send_keys_repeatedly(after, 1, 0, keys, ...)
end
]]--


-- Support chaining key jobs, such as sending keys and modifiers, repeating
-- key sequences, et cetera.

-- Simply tap some keys:
-- mb.keys.tap("abc")

-- Throw in some delay to allow applications to catch up with speedy key input:
-- mb.keys.after(100).tap("abc").after(100).tap("def")

-- Press and hold one or more modifiers while tapping a sequence of keys:
-- mb.keys.mod(keybow.LEFT_SHIFT, keybow.LEFT_CTRL).tap("abc").tap(keybow.F10)

-- More elaborate version, but without automatic enclosing:
-- mb.keys.setmods(keybow.LEFT_SHIFT).keys("abc").releasemods(keybow.LEFT_SHIFT)

-- Repeat a sequence of key operations:
-- mb.keys.times(2).tap("abc").after(100).tap("def")

-- Repeat a sequence, then send some final taps:
-- mb.keys.times(2).tap("abc").fin.tap("def")


local Keys = {
    op = nil, -- current operation to be done when we hit the table call.
}

-- When an element (field) of the "keys" table is getting read that doesn't
-- exist (is nil), then the __index method gets triggered, so we can check for
-- any of our chaining functions. Please note that we must NOT hide the other
-- fields that aren't chaining functions.
function Keys.__index(self, key)
    -- Try to look up the missing field as a chain operator; only if that
    -- succeeds, then remember the chain operator for a following table call
    -- operation. Otherwise, handle the field as any ordinary field.
    local val = rawget(mb._keys, "op_" .. key)
    if val then
        self.op = val
        return self -- ...always return ourselves for further chaining.
    end
    return rawget(self, key)
end

-- When the "keys" table is being called as a function then activate the
-- most recent operation; this basically emulates methods using ordinary
-- table field and function call syntax.
function Keys.__call(self, ...)
    if self.op then
        self.op(self, ...)
        self.op = nil
    end
    return self -- ...always return ourselves for further chaining.
end


mb._keys = Keys

-- Initializes/resets the "virtual" mb.keys object each time it gets accessed
-- anew, so chained key operations always start in a well-known initial state.
function Keys:new() -- luacheck: ignore 212/self
    local k = {
        afterms = 0,
        jobs = {},
    }
    k = setmetatable(k, Keys)
    return k
end


function Keys:op_after(ms)
    self.afterms = self.afterms + ms
    return self
end


function Keys:op_tap(keys)
    return self
end


function Keys:op_mod(...)
    return self
end

function Keys:op_times(t)
    self.jobs[#self.jobs + 1] = {} -- FIXME
    return self
end

-- Ends the most recent "block" in a chain, such as a times() and mod() block:
-- this pops the current job of the stack of "open" key jobs.
function Keys:op_fin()
    if #self.jobs > 0 then
        table.remove(self.jobs, #self.jobs)
    end
    return self
end


-- Sets up a "virtual" mb.keys object that is returned in a defined init state
-- each time the "mb.keys" element gets accessed.
setmetatable(mb, {
    -- When a non-existing table element/field is to be accessed...
    __index = function(self, key)
        if key == "keys" then
            return Keys:new()
        else
            return rawget(self, key)
        end
    end
})
