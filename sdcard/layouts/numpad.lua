local mp = _G.mp or {}
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
mp.A1 = mp.A1 or 11
mp.A2 = mp.A2 or 10
mp.A3 = mp.A3 or 9

mp.B1 = mp.B1 or 8
mp.B2 = mp.B2 or 7
mp.B3 = mp.B3 or 6

mp.C1 = mp.C1 or 5
mp.C2 = mp.C2 or 4
mp.C3 = mp.C3 or 3

mp.D1 = mp.D1 or 2
mp.D2 = mp.D2 or 1
mp.D3 = mp.D3 or 0

-- Setup shift key
function mp.unshift(_)
    mb.activate_keymap(mp.keymap.name)
end

-- The keymap layout...
mp.keymap = {
    name="mp",
    -- A1 is the shift key, so we skip that
    [mp.A2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("0") end},
    [mp.A3] = { c={r=0, g=0, b=1}, press=function() mb.tap(keybow.ENTER) end},
    [mp.B1] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("9") end},
    [mp.B2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("6") end},
    [mp.B3] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("3") end},
    [mp.C1] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("8") end},
    [mp.C2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("5") end},
    [mp.C3] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("2") end},
    [mp.D1] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("7") end},
    [mp.D2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("4") end},
    [mp.D3] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("1") end},
}

mp.keymap_shifted = {
    name="mp-shifted",
    secondary=true,

    [mp.A2] = { c={r=0, g=1, b=0}, press=function() mb.tap(".") end},
    [mp.A3] = { c={r=0, g=1, b=0}, press=function() mb.tap(",") end},
    [mp.B1] = { c={r=0, g=1, b=1}, press=function() mb.tap("+") end},
    [mp.C1] = { c={r=0, g=1, b=1}, press=function() mb.tap("-") end},
    [mp.D1] = { c={r=0, g=1, b=1}, press=function() mb.tap("=") end},
    [mp.B2] = { c={r=0, g=1, b=1}, press=function() mb.tap("/") end},
    [mp.C2] = { c={r=0, g=1, b=1}, press=function() mb.tap("%") end},
    [mp.D2] = { c={r=1, g=1, b=0}, press=function() mb.tap("$") end},
    [mp.B3] = { c={r=1, g=0, b=0}, press=function() mb.tap(keybow.BACKSPACE) end},
    [mp.C3] = { c={r=1, g=0, b=0}, press=function() mb.tap(keybow.DELETE) end},
    --[mp.D3] = { c={r=0.5, g=0.5, b=1}, press=function() mb.tap(keybow.ESC) end},

    [-1] = {release=mp.unshift},
}
mp.keymap.shift_to = mp.keymap_shifted
mp.keymap_shifted.shift_to = mp.keymap

mb.register_keymap(mp.keymap)
mb.register_keymap(mp.keymap_shifted)
return mp
