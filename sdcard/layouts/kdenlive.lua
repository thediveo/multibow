-- A Multibow keyboard layout for the Kdenlive (https://kdenlive.org/) open
-- source non-linear video editor.

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


-- allow users to set their own configuration before req'ing this
-- module, in order to control the key layout. For defaults, please see
-- below.
local k = _G.kdenlive or {} -- module

local mb = require("snippets/multibow")

-- luacheck: ignore 614
--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

              ┋┋
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 11 ┊  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
          ⍇       ⍈     
        (⯬)     (⯮)

]]--

k.KEY_PLAY_AROUND_MOUSE = k.KEY_PLAY_AROUND_MOUSE or 10

k.KEY_ZONE_BEGIN = k.KEY_ZONE_BEGIN or 7
k.KEY_ZONE_END = k.KEY_ZONE_END or 4

k.KEY_CLIP_BEGIN = k.KEY_CLIP_BEGIN or 6
k.KEY_CLIP_END = k.KEY_CLIP_END or 3
k.KEY_PROJECT_BEGIN = k.KEY_PROJECT_BEGIN or 6
k.KEY_PROJECT_END = k.KEY_PROJECT_END or 3

-- (Default) key colors for unshifted and shifted keys.
k.COLOR_UNSHIFTED = k.COLOR_UNSHIFTED or {r=0, g=1, b=0}
k.COLOR_SHIFTED = k.COLOR_SHIFTED or {r=1, g=0, b=0}


function k.play_around_mouse(...)
    mb.tap("p")
    mb.tap_times(keybow.LEFT_ARROW, 3, keybow.LEFT_SHIFT)
    mb.tap("i")
    mb.tap_times(keybow.RIGHT_ARROW, 3, keybow.LEFT_SHIFT)
    mb.tap("o")
    mb.tap(...)
end


-- Unshift to primary keymap. For simplification, use it with the "anykey"
-- release handlers, see below.
function k.unshift(_)
    mb.activate_keymap(k.keymap.name)
end

-- Helps avoiding individual color setting...
function k.init_color(keymap, color)
    for keyno, keydef in pairs(keymap) do
        if type(keyno) == "number" and keyno >= 0 then
            if not keydef.c then
                keydef.c = color
            end
        end
    end
    return keymap
end

k.keymap = k.init_color({
    name="kdenlive",
    [k.KEY_ZONE_BEGIN] = {press=function() mb.tap("I") end},
    [k.KEY_ZONE_END] = {press=function() mb.tap("O") end},
    [k.KEY_CLIP_BEGIN] = {press=function() mb.tap(keybow.HOME) end},
    [k.KEY_CLIP_END] = {press=function() mb.tap(keybow.END) end},
    [k.KEY_PLAY_AROUND_MOUSE] = {press=function() k.play_around_mouse(keybow.SPACE, keybow.LEFT_CTRL) end},
}, k.COLOR_UNSHIFTED)
k.keymap_shifted = k.init_color({
    name="kdenlive-shifted",
    secondary=true,
    [k.KEY_PROJECT_BEGIN] = {press=function() mb.tap(keybow.HOME, keybow.LEFT_CTRL) end},
    [k.KEY_PROJECT_END] = {press=function() mb.tap(keybow.END, keybow.LEFT_CTRL) end},
    [k.KEY_PLAY_AROUND_MOUSE] = {press=function() k.play_around_mouse(keybow.SPACE, keybow.LEFT_ALT) end},
    [-1] = {release=k.unshift},
}, k.COLOR_SHIFTED)
k.keymap.shift_to = k.keymap_shifted
k.keymap_shifted.shift_to = k.keymap

mb.register_keymap(k.keymap)
mb.register_keymap(k.keymap_shifted)


return k -- module
