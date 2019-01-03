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
  -- Check key in permanent keymaps
  local keydef
  for name, pkm in pairs(mb.permanent_keymaps) do
    keydef = pkm[keyno]
    if keydef ~= nil then; break; end
  end
  -- Check key in current keymap
  if keydef == nil and mb.current_keymap_set ~= nil then
    keydef = mb.current_keymap_set[mb.current_keymap_idx][keyno]
  end

  if keydef == nil then; return; end

  if pressed then
    for led = 0, 11 do
      if led ~= keyno then; mb.led(led, {r=0, g=0, b=0}); end
    end
    print("route to key #", keyno)
    keydef.h(keyno)
  else
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
