-- A Multibow keyboard layout for the VisualStudio Go extension
-- (https://github.com/Microsoft/vscode-go).

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

local vscgo = _G.vscgo or {} -- module

local mb = require "snippets/multibow"

--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

              ┋┋
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 11 ┊  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

╔════╗  ╔════╗  ┌╌╌╌╌┐  ╔════╗
║ 10 ║  ║  7 ║  ┊  4 ┊  ║  1 ║
╚════╝  ╚════╝  └╌╌╌╌┘  ╚════╝
⏹STOP   ↺RELOAD         TSTPKG
╔════╗  ╔════╗  ╔════╗  ╔════╗
║  9 ║  ║  6 ║  ║  3 ║  ║  0 ║
╚════╝  ╚════╝  ╚════╝  ╚════╝
  ▮▶    ⮧INTO   ⭢STEP   ⮥OUT

]]--

-- Default hardware key to function assignments, can be overriden by users
vscgo.KEY_STOP = vscgo.KEY_STOP or 10
vscgo.KEY_RELOAD = vscgo.KEY_RELOAD or 7
vscgo.KEY_TESTPKG = vscgo.KEY_TESTPKG or 1
vscgo.KEY_CONT = vscgo.KEY_CONT or 9
vscgo.KEY_STEPINTO = vscgo.KEY_STEPINTO or 6
vscgo.KEY_STEPOVER = vscgo.KEY_STEPOVER or 3
vscgo.KEY_STEPOUT = vscgo.KEY_STEPOUT or 0

vscgo.RED = { r=1, g=0, b=0 }
vscgo.YELLOW = { r=1, g=0.7, b=0 }
vscgo.GREEN = { r=0, g=1, b=0 }
vscgo.BLUE = { r=0, g=0, b=1 }
vscgo.BLUECYAN = { r=0, g=0.7, b=1 }
vscgo.BLUEGRAY = { r=0.7, g=0.7, b=1 }
vscgo.CYAN = { r=0, g=1, b=1 }

vscgo.COLOR_STOP = vscgo.COLOR_STOP or vscgo.RED
vscgo.COLOR_RELOAD = vscgo.COLOR_RELOAD or vscgo.YELLOW
vscgo.COLOR_TESTPKG = vscgo.COLOR_TESTPKG or vscgo.CYAN
vscgo.COLOR_CONT = vscgo.COLOR_CONT or vscgo.GREEN
vscgo.COLOR_STEPINTO = vscgo.COLOR_STEPINTO or vscgo.BLUECYAN
vscgo.COLOR_STEPOVER = vscgo.COLOR_STEPOVER or vscgo.BLUE
vscgo.COLOR_STEPOUT = vscgo.COLOR_STEPOUT or vscgo.BLUEGRAY


-- AND NOW FOR SOMETHING DIFFERENT: THE REAL MEAT --

function vscgo.debug_stop(_)
  mb.tap(keybow.F5, keybow.LEFT_SHIFT)
end

function vscgo.debug_restart(_)
  mb.tap(keybow.F5, keybow.LEFT_SHIFT, keybow.LEFT_CTRL)
end

function vscgo.debug_continue(_)
  mb.tap(keybow.F5)
end

function vscgo.debug_stepover(_)
  mb.tap(keybow.F10)
end

function vscgo.debug_stepinto(_)
  mb.tap(keybow.F11)
end

function vscgo.debug_stepout(_)
  mb.tap(keybow.F11, keybow.LEFT_SHIFT)
end

function vscgo.go_test_package(_)
  mb.tap("P", keybow.LEFT_SHIFT, keybow.LEFT_CTRL)
  keybow.sleep(250)
  keybow.text("go test package")
  keybow.tap_enter()
end

vscgo.keymap = {
  name="vsc-golang-debug",
  [vscgo.KEY_STOP] = {c=vscgo.COLOR_STOP, press=vscgo.debug_stop},
  [vscgo.KEY_RELOAD] = {c=vscgo.COLOR_RELOAD, press=vscgo.debug_restart},
  [vscgo.KEY_TESTPKG] = {c=vscgo.COLOR_TESTPKG, press=vscgo.go_test_package},

  [vscgo.KEY_CONT] = {c=vscgo.COLOR_CONT, press=vscgo.debug_continue},
  [vscgo.KEY_STEPINTO] = {c=vscgo.COLOR_STEPINTO, press=vscgo.debug_stepinto},
  [vscgo.KEY_STEPOVER] = {c=vscgo.COLOR_STEPOVER, press=vscgo.debug_stepover},
  [vscgo.KEY_STEPOUT] = {c=vscgo.COLOR_STEPOUT, press=vscgo.debug_stepout},
}

mb.register_keymap(vscgo.keymap)

return vscgo -- module
