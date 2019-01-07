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

require("keybow")
local mk = require("snippets/morekeys")
local mb = require("snippets/multibow")


k.KEY_CLIP_BEGIN = k.KEY_CLIP_BEGIN or 9
k.KEY_PROJECT_BEGIN = k.KEY_PROJECT_BEGIN or 9

k.KEY_CLIP_END = k.KEY_CLIP_END or 0
k.KEY_PROJECT_END = k.KEY_PROJECT_END or 0

-- (Default) key colors for unshifted and shifted keys.
k.COLOR_UNSHIFTED = k.COLOR_UNSHIFTED or {r=0, g=1, b=0}
k.COLOR_SHIFTED = k.COLOR_SHIFTED or {r=1, g=0, b=0}


-- Unshift to primary keymap. For simplification, use it with the "anykey"
-- release handlers, see below.
function k.unshift(keyno)
    mb.activate_keymap(k.keymap.name)
end

k.keymap = {
    name="kdenlive",
    [k.KEY_CLIP_BEGIN] = {c=k.COLOR_UNSHIFTED, press=function() mb.tap(mk.HOME) end},
    [k.KEY_CLIP_END] = {c=k.COLOR_UNSHIFTED, press=function() mb.tap(mk.END) end},
}
k.keymap_shifted = {
    name="kdenlive-shifted",
    secondary=true,
    [k.KEY_PROJECT_BEGIN] = {c=k.COLOR_SHIFTED, press=function() mb.tap(mk.HOME, keybow.LEFT_CTRL) end},
    [k.KEY_PROJECT_END] = {c=k.COLOR_SHIFTED, press=function() mb.tap(mk.END, keybow.LEFT_CTRL) end},
    [-1] = {release=k.unshift},
}
k.keymap.shift_to = k.keymap_shifted
k.keymap_shifted.shift_to = k.keymap

mb.register_keymap(k.keymap)
mb.register_keymap(k.keymap_shifted)


return k -- module
