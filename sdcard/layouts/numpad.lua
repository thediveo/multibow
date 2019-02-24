local km = _G.km or {}
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
km.A1 = km.A1 or 11
km.A2 = km.A2 or 10
km.A3 = km.A3 or 9

km.B1 = km.B1 or 8
km.B2 = km.B2 or 7
km.B3 = km.B3 or 6

km.C1 = km.C1 or 5
km.C2 = km.C2 or 4
km.C3 = km.C3 or 3

km.D1 = km.D1 or 2
km.D2 = km.D2 or 1
km.D3 = km.D3 or 0

-- Setup shift key
function km.unshift(_)
    mb.activate_keymap(km.keymap.name)
end

-- The keymap layout...
km.keymap = {
    name="numpad",
    -- A1 is the shift key, so we skip that
    [km.A2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("0") end},
    [km.A3] = { c={r=0, g=0, b=1}, press=function() mb.tap(keybow.ENTER) end},
    [km.B1] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("9") end},
    [km.B2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("6") end},
    [km.B3] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("3") end},
    [km.C1] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("8") end},
    [km.C2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("5") end},
    [km.C3] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("2") end},
    [km.D1] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("7") end},
    [km.D2] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("4") end},
    [km.D3] = { c={r=0, g=1, b=0.5}, press=function() mb.tap("1") end},
}

km.keymap_shifted = {
    name="numpad-shifted",
    secondary=true,

    [km.A2] = { c={r=0, g=1, b=0}, press=function() mb.tap(".") end},
    [km.A3] = { c={r=0, g=1, b=0}, press=function() mb.tap(",") end},
    [km.B1] = { c={r=0, g=1, b=1}, press=function() mb.tap("+") end},
    [km.C1] = { c={r=0, g=1, b=1}, press=function() mb.tap("-") end},
    [km.D1] = { c={r=0, g=1, b=1}, press=function() mb.tap("=") end},
    [km.B2] = { c={r=0, g=1, b=1}, press=function() mb.tap("/") end},
    [km.C2] = { c={r=0, g=1, b=1}, press=function() mb.tap("%") end},
    [km.D2] = { c={r=1, g=1, b=0}, press=function() mb.tap("$") end},
    [km.B3] = { c={r=1, g=0, b=0}, press=function() mb.tap(keybow.BACKSPACE) end},
    [km.C3] = { c={r=1, g=0, b=0}, press=function() mb.tap(keybow.DELETE) end},
    --[km.D3] = { c={r=0.5, g=0.5, b=1}, press=function() mb.tap(keybow.ESC) end},

    [-1] = {release=km.unshift},
}
km.keymap.shift_to = km.keymap_shifted
km.keymap_shifted.shift_to = km.keymap

mb.register_keymap(km.keymap)
mb.register_keymap(km.keymap_shifted)

