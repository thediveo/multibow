-- Tests all available multibow layouts in a single setup, thus trying to
-- mimic the final Keybow firmware installation as close as possible (for some
-- suitable definition of "close").

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

require("mocked-keybow")

require "layouts/shift"
require "layouts/kdenlive"
local vscgolang = require "layouts/vsc-golang"
require "layouts/empty"

local mb = require("snippets/multibow")
local hwk = require("spec/hwkeys")

describe("final Multibow integration", function()

    _G.setup()

    it("integrates all keymaps", function()
        local kms = mb.registered_keymaps()
        -- shift: 2 registered keymaps
        -- vsc-golang: 1 reg keymap
        -- kdenlive: 2 reg keymaps
        -- empty: 1 reg keymap
        assert.is.equal(6, #kms)
    end)

    -- inslit() is an insulated(it()) ensuring that all stubs and spies get
    -- removed after this test in any case.
    inslit("starts gonelang debugging :)", function()
        -- Switches to the VSC Golang Multibow keymap, regardless of the
        -- order of keymap imports.
        mb.activate_keymap(vscgolang.keymap.name)
        assert.is.equal(vscgolang.keymap.name, mb.current_keymap.name)
        assert.is.equal(vscgolang.go_test_package, vscgolang.keymap[vscgolang.KEY_TESTPKG].press)

        -- Checks that a press of the "Continue Debugging" key does in fact
        -- trigger the corresponding keymap handler.
        local s = stub(vscgolang.keymap[vscgolang.KEY_CONT], "press")
        hwk.tap(vscgolang.KEY_STEPOVER)
        assert.stub(s).was_not.called()
        hwk.tap(vscgolang.KEY_CONT)
        assert.stub(s).was.called(1)
    end)

end)
