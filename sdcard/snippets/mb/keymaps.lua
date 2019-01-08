-- Multibow internal "module" implementing keymap-related management and
-- handling.

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

-- Internal variables for housekeeping...

-- The registered keymaps, indexed by their names (.name field).
mb.keymaps = {}
-- The ordered sequence of primary keymap, in the sequence they were
-- registered.
mb.primary_keymaps = {}
-- The currently activated keymap.
mb.current_keymap = nil
-- A temporary keymap while grabbing.
mb.grab_keymap = nil

-- Registers a keymap (by name), so it can be easily activated later by its name.
-- Multiple keymaps can be registered. Keymaps can be either "primary" by
-- default, or permanent or secondary keymaps.
--
-- A primary keymap is any keymap without either a "permanent" or "secondary"
-- table element. Users can cycle through primary keymaps using the "shift"
-- permanent keyboard layout.
--
-- permanent keymaps (marked by table element "permanent=true") are always
-- active, thus they don't need to be activated.
--
-- Secondary keymaps (marked by table element "secondary=true") are intended
-- as SHIFT/modifier layers. As such the get ignored by cycling, but instead
-- need to be activated explicitly. The "shift" permanent keyboard layout
-- automates this.
--
-- If this is the first keymap getting registered, then it will also made
-- activated.
function mb.register_keymap(keymap)
    local name = keymap.name
    -- register
    mb.keymaps[name] = keymap
    -- ensure that first registered keymap also automatically gets activated
    -- (albeit the LEDs will only update later). Also maintain the (ordered)
    -- sequence of registered primary keymaps.
    if not (keymap.permanent or keymap.secondary) then
        mb.current_keymap = mb.current_keymap or keymap
        table.insert(mb.primary_keymaps, keymap)
    end
end

-- Returns the list of currently registered keymaps; this list is a table,
-- with its registered keymaps at indices 1, 2, ...
function mb.registered_keymaps()
    local keymaps = {}
    for _, keymap in pairs(mb.keymaps) do
        table.insert(keymaps, keymap)
    end
    return keymaps
end

-- Returns the list of currently registered *primary* keymaps, in the same order
-- as they were registered. First primary is at index 1, second at 2, ...
function mb.registered_primary_keymaps()
    return mb.primary_keymaps
end

-- Cycles through the available (primary) keymaps, ignoring secondary and
-- permanent keymaps. This is convenient for assigning primary keymap switching
-- using a key on the Keybow device itself.
function mb.cycle_primary_keymaps()
    local km = mb.current_keymap
    if km == nil then return end
    -- If this is a secondary keymap, locate its corresponding primary keymap.
    if km.secondary then
        if not km.shift_to then
            -- No SHIFT's shift_to cyclic chain available, so rely on the naming
            -- schema instead and try to locate the primary keymap with the first
            -- match instead. This assumes that the name of the secondary keymaps
            -- have some suffix and thus are longer than the name of their
            -- corresponding primary keymap.
            for _, pkm in ipairs(mb.primary_keymaps) do
                if string.sub(km.name, 1, #pkm.name) == pkm.name then
                    km = pkm
                    break
                end
            end
            -- Checks if locating the primary keymap failed and then bails out
            -- immediately.
            if km.secondary then return end
        else
            -- Follows the cyclic chain of SHIFT's shift_to keymaps, until we get
            -- to the primary keymap in the cycle, or until we have completed one
            -- cycle.
            repeat
                km = km.shift_to
                if not km or km == mb.current_keymap then
                    return
                end
            until not(km.secondary)
        end
    end
    -- Move on to the next primary keymap, rolling over at the end of our list.
    for idx, pkm in ipairs(mb.primary_keymaps) do
        if pkm == km then
            idx = idx + 1
            if idx > #mb.primary_keymaps then idx = 1 end
            mb.activate_keymap(mb.primary_keymaps[idx].name)
        end
    end
end

-- Activates a specific keymap by name. Please note that it isn't necessary
-- to "activate" permanent keymaps at all (and thus this deed cannot be done).
function mb.activate_keymap(name)
    name = type(name) == "table" and name.name or name
    local keymap = mb.keymaps[name]
    if keymap and not keymap.permanent then
        mb.current_keymap = keymap
        mb.activate_leds()
    end
end

-- Sets a "grabbing" keymap that takes (temporarily) grabs all keys. While a
-- grab keymap is in place, key presses and releases will only be routed to
-- the grab keymap, but never to the permanent keymaps, nor the previously
-- "active" primary keymap.
function mb.grab(name)
    name = type(name) == "table" and name.name or name
    mb.grab_keymap = mb.keymaps[name]
    mb.activate_leds()
end

-- Removes a "grabbing" keymap, thus reactivating the permanent keymaps, as
-- well as the previously active primary keymap.
function mb.ungrab()
    mb.grab_keymap = nil
    mb.activate_leds()
end
