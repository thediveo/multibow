-- A Multibow simple media player keyboard layout.

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

local mplay = _G.mplay or {} -- module

local mb = require("snippets/multibow")

--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

              ┋┋
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 11 ┊  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
          🔇     🔈/🔉     🔊
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
                  ⏹️️
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
          ◀️◀️      ▮▶      ▶▶

]]--

mplay.KEY_STOP = mplay.KEY_STOP or 4
mplay.KEY_PLAYPAUSE = mplay.KEY_PLAYPAUSE or 3
mplay.KEY_PREV = mplay.KEY_PREV or 6
mplay.KEY_NEXT = mplay.KEY_NEXT or 0

mplay.KEY_VOLUP = mplay.KEY_VOLUP or 2
mplay.KEY_VOLDN = mplay.KEY_VOLDN or 5
mplay.KEY_MUTE = mplay.KEY_MUTE or 8

mplay.keymap = {
    name="mediaplayer",

    [mplay.KEY_STOP] = { c={r=1, g=0, b=0}, press=function() mb.tap(keybow.MEDIA_STOPCD) end},
    [mplay.KEY_PLAYPAUSE] = { c={r=0, g=1, b=0}, press=function() mb.tap(keybow.MEDIA_PLAYPAUSE) end},
    [mplay.KEY_PREV] = { c={r=0.5, g=0.5, b=1}, press=function() mb.tap(keybow.MEDIA_PREVIOUSSONG) end},
    [mplay.KEY_NEXT] = { c={r=0, g=1, b=1}, press=function() mb.tap(keybow.MEDIA_NEXTSONG) end},

    [mplay.KEY_MUTE] = { c={r=0.5, g=0.1, b=0.1}, press=function() mb.tap(keybow.MEDIA_MUTE) end},
    [mplay.KEY_VOLDN] = { c={r=0.5, g=0.5, b=0.5}, press=function() mb.tap(keybow.MEDIA_VOLUMEDOWN) end},
    [mplay.KEY_VOLUP] = { c={r=1, g=1, b=1}, press=function() mb.tap(keybow.MEDIA_VOLUMEUP) end},
}
mb.register_keymap(mplay.keymap)

return mplay -- module
