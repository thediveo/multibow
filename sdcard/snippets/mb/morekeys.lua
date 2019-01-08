-- Multibow module providing additional USB HID keycode definitions to augment
-- the existing keybow definitions. For more information about USB HID
-- keyboard scan codes, for instance, see:
-- https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2

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

require("keybow")

-- Tell luacheck that it is okay in this specific case to change the keybow
-- global.

-- luacheck: globals keybow

keybow.SYSRQ = 0x46
keybow.SCROLLLOCK = 0x47
keybow.PAUSE = 0x48
keybow.INSERT = 0x49
keybow.DELETE = 0x4c
keybow.HOME = 0x4a
keybow.END = 0x4d
keybow.PAGEUP = 0x4b
keybow.PAGEOWN = 0x4e

keybow.F13 = 0x68
keybow.F14 = 0x69
keybow.F15 = 0x6a
keybow.F16 = 0x6b
keybow.F17 = 0x6c
keybow.F18 = 0x6d
keybow.F19 = 0x6e
keybow.F20 = 0x6f
keybow.F21 = 0x70
keybow.F22 = 0x71
keybow.F23 = 0x72
keybow.F24 = 0x73

keybow.KPSLASH = 0x54
keybow.KPASTERISK = 0x55
keybow.KPMINUS = 0x56
keybow.KPPLUS = 0x57
keybow.KPENTER = 0x58
keybow.KP1 = 0x59
keybow.KP2 = 0x5a
keybow.KP3 = 0x5b
keybow.KP4 = 0x5c
keybow.KP5 = 0x5d
keybow.KP6 = 0x5e
keybow.KP7 = 0x5f
keybow.KP8 = 0x60
keybow.KP9 = 0x61
keybow.KP0 = 0x62
keybow.KPDOT = 0x63
keybow.KPEQUAL = 0x67

keybow.COMPOSE = 0x65
keybow.POWER = 0x66

keybow.OPEN = 0x74
keybow.HELP = 0x75
keybow.PROPS = 0x76
keybow.FRONT = 0x77
keybow.STOP = 0x78
keybow.AGAIN = 0x79
keybow.UNDO = 0x7a
keybow.CUT = 0x7b
keybow.COPY = 0x7c
keybow.PASTE = 0x7d
keybow.FIND = 0x7e
keybow.MUTE = 0x7f
keybow.VOLUMEUP = 0x80
keybow.VOLUMEDOWN = 0x81

keybow.MEDIA_PLAYPAUSE = 0xe8
keybow.MEDIA_STOPCD = 0xe9
keybow.MEDIA_PREVIOUSSONG = 0xea
keybow.MEDIA_NEXTSONG = 0xeb
keybow.MEDIA_EJECTCD = 0xec
keybow.MEDIA_VOLUMEUP = 0xed
keybow.MEDIA_VOLUMEDOWN = 0xee
keybow.MEDIA_MUTE = 0xef
keybow.MEDIA_WWW = 0xf0
keybow.MEDIA_BACK = 0xf1
keybow.MEDIA_FORWARD = 0xf2
keybow.MEDIA_STOP = 0xf3
keybow.MEDIA_FIND = 0xf4
keybow.MEDIA_SCROLLUP = 0xf5
keybow.MEDIA_SCROLLDOWN = 0xf6
keybow.MEDIA_EDIT = 0xf7
keybow.MEDIA_SLEEP = 0xf8
keybow.MEDIA_COFFEE = 0xf9
keybow.MEDIA_REFRESH = 0xfa
keybow.MEDIA_CALC = 0xfb


return keybow -- module
