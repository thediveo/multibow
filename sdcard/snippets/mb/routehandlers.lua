-- Part of Multibow

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
]] --

-- This all-key, central key router forwards Keybow key events to their
-- correct handlers, depending on which keyboard layout currently is active.
--
-- A keymap grab will always only route keys to the "grabbing" keymap, and to
-- no other keymap. Without a keymap grab in place, permanent keymaps will be
-- searched first for a matching key definition, with the first hit to score.
-- The current keymap will be considered only last, after all permanent
-- keymaps have been exhausted.
--
-- Additionally, "any" keyhandlers will be considered only for (1) the
-- grabbing keymap (if a grab is active) and for (2) the current keymap.
-- Permanent keymaps cannot have "any" key handlers (or rather, they will be
-- ignored.)
function mb.route(keyno, pressed)
    local keydef, any_kdeydef
    -- Checks for a keymap grab being enforced at this time; if the grabbing
    -- keymap does not define the key, then it's game over. Additionally,
    -- grabbing keymaps may define "any" handlers.
    if mb.grab_keymap then
        keydef = mb.grab_keymap[keyno]
        any_kdeydef = mb.grab_keymap[-1]
    else
        -- No grab in place, so continue checking for a matching key in the
        -- permanent keymaps first. Remember, there cannot be "any" handlers
        -- with permanent keymaps.
        for name, keymap in pairs(mb.keymaps) do
            if keymap.permanent then
                keydef = keymap[keyno]
                if keydef then
                    break
                end
            end
        end
        -- If no permanent key matched then finally check for our key in the
        -- current keymap. Additionally, the current keymap is allowed to
        -- define an "any" handler.
        if not keydef and mb.current_keymap then
            keydef = mb.current_keymap[keyno]
            any_kdeydef = mb.current_keymap[-1]
        end
    end

    -- Bails out now if either a specific nor an "any" key definition to route
    -- to could be found.
    if not (keydef or any_kdeydef) then
        return
    end

    -- We found a route, so we need to call its associated handler and
    -- also handle the LED lightshow.
    if pressed then
        for led = 0, 11 do
            if led ~= keyno then
                mb.led(led, {r = 0, g = 0, b = 0})
            end
        end

        if keydef and keydef.press then keydef.press(keyno) end
        if any_kdeydef and any_kdeydef.press then any_kdeydef.press(keyno) end
    else
        if keydef and keydef.release then keydef.release(keyno) end
        if any_kdeydef and any_kdeydef.release then any_kdeydef.release(keyno) end

        mb.activate_leds()
    end
end

-- Routes all keybow key handling through our central key router
-- by creating the required set of global handler functions expected
-- by the Keybow firmware.
for keyno = 0, 11 do
    _G[string.format("handle_key_%02d", keyno)] = function(pressed)
        mb.route(keyno, pressed)
    end
end
