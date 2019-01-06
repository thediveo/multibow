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

-- This all-key, central key router forwards Keybow key events to
-- their correct handlers, depending on which keyboard layout currently
-- is active.
function mb.route(keyno, pressed)
    local keydef, grabbed_any_keydef, anykdeydef
    -- Checks for a keymap grab being enforced at this time...
    if mb.grab_keymap then
        keydef = mb.grab_keymap[keyno]
        grabbed_any_keydef = mb.grab_keymap[-1]
    else
        -- Checks for key in permanent keymaps first...
        for name, keymap in pairs(mb.keymaps) do
            if keymap.permanent then
                keydef = keymap[keyno]
                if keydef then
                    break
                end
            end
        end
        -- Checks for key in current keymap if no persistent key was found yet.
        if not keydef then
            if mb.current_keymap then
                keydef = mb.current_keymap[keyno]
                anykeydef = mb.current_keymap[-1]
            end
        end
    end

    -- Bails out if no key definition to route to could be found.
    if not (keydef or anykeydef or grabbed_any_keydef) then
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
        if grabbed_any_keydef and grabbed_any_keydef.press then
            grabbed_any_keydef.press(keyno)
        end
        if keydef and keydef.press then
            keydef.press(keyno)
        end
        if anykeydef and anykeydef.press then
            anykeydef.press(keyno)
        end
    else
        if grabbed_any_keydef and grabbed_any_keydef.release then
            grabbed_any_keydef.release(keyno)
        end
        if keydef and keydef.release then
            keydef.release(keyno)
        end
        if anykeydef and anykeydef.release then
            anykeydef.release(keyno)
        end
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
