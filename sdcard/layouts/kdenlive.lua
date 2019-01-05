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

local mb = require "snippets/multibow"



k = {} -- module

-- Key colors for unshifted and shifted keys; keep them rather muted in order
-- to not distract your video editing work.
k.UNSHIFTED_COLOR = {r=0, g=50, b=0}
k.SHIFTED_COLOR = {r=50, g=0, b=0}
k.keymap = {
    name="kdenlive",
    [9] = {c={0,1,0}}
}
k.keymap_shifted = {
    name="kdenlive-shifted",
    secondary=true,
    [9] = {c={1,0,0}}
}
k.keymap.shift_to = k.keymap_shifted
k.keymap_shifted.shift_to = k.keymap
mb.register_keymap(k.keymap)
mb.register_keymap(k.keymap_shifted)


return k -- module