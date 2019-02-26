local i3 = _G.i3 or {}
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
i3.A1 = i3.A1 or 11
i3.A2 = i3.A2 or 10
i3.A3 = i3.A3 or 9

i3.B1 = i3.B1 or 8
i3.B2 = i3.B2 or 7
i3.B3 = i3.B3 or 6

i3.C1 = i3.C1 or 5
i3.C2 = i3.C2 or 4
i3.C3 = i3.C3 or 3

i3.D1 = i3.D1 or 2
i3.D2 = i3.D2 or 1
i3.D3 = i3.D3 or 0

function i3.command(cmd)
    mb.tap(keybow.SUPER)
    keybow.sleep(50)
    mb.tap(cmd)
end

function i3.exit()
    keybow.text("exit")
    keybow.tap_enter()
end

i3.keymap = {
    name="i3",
    [i3.A2] = { c={r=0, g=1, b=1}, press=function(_) i3.command("v") end},
    [i3.B1] = { c={r=0, g=1, b=1}, press=function(_) i3.command("b") end},
    [i3.B2] = { c={r=0, g=0.5, b=1}, press=function(_) i3.command("f") end},

    [i3.C1] = { c={r=1, g=1, b=0}, press=function(_) i3.command("h") end},
    [i3.D1] = { c={r=1, g=1, b=0}, press=function(_) i3.command("l") end},

    [i3.D2] = { c={r=1, g=0, b=1}, press=function(_) i3.command("k") end},
    [i3.D3] = { c={r=1, g=0, b=1}, press=function(_) i3.command("j") end},

    [i3.B3] = { c={r=0.5, g=1, b=0.5}, press=function(_) i3.command("p") end},
    [i3.C3] = { c={r=0.5, g=1, b=0.5}, press=function(_) i3.command("n") end},

    [i3.A3] = { c={r=1, g=0, b=0}, press=function(_) i3.exit() end},

}

mb.register_keymap(i3.keymap)
return i3
