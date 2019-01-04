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

-- This all-key, central key router forwards Keybow key events to
-- their correct handlers, depending on which keyboard layout currently
-- is active.
function mb.route(keyno, pressed)
  local keydef
  -- Checks for a keymap grab being enforced at this time...
  if mb.grab_keymap then
    print("routing GRABBED key")
    keydef = mb.grab_keymap[keyno]
  else
    -- Checks for key in permanent keymaps first...
    for name, keymap in pairs(mb.keymaps) do
      if keymap.permanent then
        keydef = keymap[keyno]
        if keydef then; break; end
      end
    end
    -- Checks for key in current keymap if no persistent key was found yet.
    if not keydef and mb.current_keymap then
      keydef = mb.current_keymap[keyno]
    end
  end

  -- Bails out if no key definition to route to could be found.
  if not keydef then; return; end

  --
  if pressed then
    for led = 0, 11 do
      if led ~= keyno then; mb.led(led, {r=0, g=0, b=0}); end
    end
    if keydef.press then
      keydef.press(keyno)
    end
  else
    if keydef.release then
      keydef.release(keyno)
    end
    mb.activate_leds()
  end
end

-- Routes all keybow key handling through our central key router
function handle_key_00(pressed); mb.route(0, pressed); end
function handle_key_01(pressed); mb.route(1, pressed); end
function handle_key_02(pressed); mb.route(2, pressed); end
function handle_key_03(pressed); mb.route(3, pressed); end
function handle_key_04(pressed); mb.route(4, pressed); end
function handle_key_05(pressed); mb.route(5, pressed); end
function handle_key_06(pressed); mb.route(6, pressed); end
function handle_key_07(pressed); mb.route(7, pressed); end
function handle_key_08(pressed); mb.route(8, pressed); end
function handle_key_09(pressed); mb.route(9, pressed); end
function handle_key_10(pressed); mb.route(10, pressed); end
function handle_key_11(pressed); mb.route(11, pressed); end
