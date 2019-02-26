local tm = _G.tm or {}
local mb = require("snippets/multibow")
--[[
The Keybow layout is as follows when in landscape orientation, with the USB
cable going off "northwards":

              ┋┋
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ A1 ┊  ┊ B1 ┊  ┊ C1 ┊  ┊ D1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ A2 ┊  ┊ B2 ┊  ┊ C2 ┊  ┊ D2 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ A3 ┊  ┊ B3 ┊  ┊ C3 ┊  ┊ D3 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

]]--
-- Instead of using 0 to 11, i renamed them to row/colums
tm.A1 = tm.A1 or 11
tm.A2 = tm.A2 or 10
tm.A3 = tm.A3 or 9

tm.B1 = tm.B1 or 8
tm.B2 = tm.B2 or 7
tm.B3 = tm.B3 or 6

tm.C1 = tm.C1 or 5
tm.C2 = tm.C2 or 4
tm.C3 = tm.C3 or 3

tm.D1 = tm.D1 or 2
tm.D2 = tm.D2 or 1
tm.D3 = tm.D3 or 0

function tm.command(cmd)
    mb.tap("`")
    keybow.sleep(50)
    mb.tap(cmd)
end

function tm.commandShiftLayout(cmd)
    mb.tap("`")
    mb.tap(cmd,keybow.LEFT_CTRL)
    keybow.sleep(50)
end

function tm.exit()
    keybow.text("exit")
    keybow.tap_enter()
end

function tm.unshift(_)
    mb.activate_keymap(tm.keymap.name)
end

tm.keymap = {
    name="tmux",
    [tm.A2] = { c={r=0, g=1, b=1}, press=function(_) tm.command("v") end},
    [tm.B1] = { c={r=0, g=1, b=1}, press=function(_) tm.command("b") end},
    [tm.B2] = { c={r=0, g=1, b=1}, press=function(_) tm.command("c") end},

    [tm.C1] = { c={r=1, g=1, b=0}, press=function(_) tm.command("h") end},
    [tm.D1] = { c={r=1, g=1, b=0}, press=function(_) tm.command("l") end},

    [tm.D2] = { c={r=1, g=0, b=1}, press=function(_) tm.command("k") end},
    [tm.D3] = { c={r=1, g=0, b=1}, press=function(_) tm.command("j") end},

    [tm.B3] = { c={r=0.5, g=1, b=0.5}, press=function(_) tm.command("p") end},
    [tm.C3] = { c={r=0.5, g=1, b=0.5}, press=function(_) tm.command("n") end},

    [tm.A3] = { c={r=1, g=0, b=0}, press=function(_) tm.exit() end},

}

tm.keymap_shifted = {
    name="tmux-shifted",
    secondary=true,

    [tm.C1] = { c={r=1, g=1, b=0}, press=function(_) tm.commandShiftLayout("h") end},
    [tm.D1] = { c={r=1, g=1, b=0}, press=function(_) tm.commandShiftLayout("l") end},

    [tm.D2] = { c={r=1, g=0, b=1}, press=function(_) tm.commandShiftLayout("k") end},
    [tm.D3] = { c={r=1, g=0, b=1}, press=function(_) tm.commandShiftLayout("j") end},

    [-1] = {release=tm.unshift},
}

tm.keymap.shift_to = tm.keymap_shifted
tm.keymap_shifted.shift_to = tm.keymap

mb.register_keymap(tm.keymap)
mb.register_keymap(tm.keymap_shifted)
return tm
