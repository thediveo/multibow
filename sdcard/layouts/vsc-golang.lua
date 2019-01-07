-- VSC Go extension debug Keybow layout

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
  ▮▶    ⭢STEP   ⮧INTO   ⮥OUT

]]--

-- Default hardware key to function assignments, can be overriden by users
vscgo.KEY_STOP = vscgo.KEY_STOP or 10
vscgo.KEY_RELOAD = vscgo.KEY_RELOAD or 7
vscgo.KEY_TESTPKG = vscgo.KEY_TESTPKG or 1
vscgo.KEY_CONT = vscgo.KEY_CONT or 9
vscgo.KEY_STEPINTO = vscgo.KEY_STEPINTO or 6
vscgo.KEY_STEPOVER = vscgo.KEY_STEPOVER or 3
vscgo.KEY_STEPOUT = vscgo.KEY_STEPOUT or 0

RED = { r=1, g=0, b=0 }
YELLOW =  { r=1, g=0.8, b=0 }
GREEN = { r=0, g=1, b=0 }
BLUE = { r=0, g=0, b=1 }
BLUECYAN = { r=0, g=0.7, b=1 }
BLUEGRAY = { r=0.7, g=0.7, b=1 }
CYAN = { r=0, g=1, b=1 }


-- AND NOW FOR SOMETHING DIFFERENT: THE REAL MEAT --

function vscgo.debug_stop(key)
  mb.tap(key, keybow.F5, keybow.LEFT_SHIFT)
end

function vscgo.debug_restart(key)
  mb.tap(key, keybow.F5, keybow.LEFT_SHIFT, keybow.LEFT_CTRL)
end

function vscgo.debug_continue(key)
  mb.tap(key, keybow.F5)
end

function vscgo.debug_stepover(key)
  mb.tap(key, keybow.F10)
end

function vscgo.debug_stepinto(key)
  mb.tap(key, keybow.F11)
end

function vscgo.debug_stepout(key)
  mb.tap(key, keybow.F11, keybow.LEFT_SHIFT)
end

function vscgo.go_test_package(key)
  mb.tap(key, "P", keybow.LEFT_SHIFT, keybow.LEFT_CTRL)
  keybow.sleep(250)
  keybow.text("go test package")
  keybow.tap_enter()
end

vscgo.keymap = {
  name="vsc-golang-debug",
  [vscgo.KEY_STOP] = {c=RED, press=vscgo.debug_stop},
  [vscgo.KEY_RELOAD] = {c=YELLOW, press=vscgo.debug_restart},
  [vscgo.KEY_TESTPKG] = {c=CYAN, press=vscgo.go_test_package},

  [vscgo.KEY_CONT] = {c=GREEN, press=vscgo.debug_continue},
  [vscgo.KEY_STEPINTO] = {c=BLUECYAN, press=vscgo.debug_stepinto},
  [vscgo.KEY_STEPOVER] = {c=BLUE, press=vscgo.debug_stepover},
  [vscgo.KEY_STEPOUT] = {c=BLUEGRAY, press=vscgo.debug_stepout},
}

mb.register_keymap(vscgo.keymap)

return vscgo -- module
