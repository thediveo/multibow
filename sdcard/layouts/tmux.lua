local tm = {}
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

tm.keymap = {
    name="tmux",
    [8] = { c={r=0, g=1, b=1}, press=function() mb.tap("`", "b") end},
    [10] = { c={r=0, g=1, b=1}, press=function() mb.tap("`", "v") end},
    [7] = { c={r=0, g=1, b=1}, press=function() mb.tap("`", "c") end},

}

mb.register_keymap(tm.keymap)
return tm
