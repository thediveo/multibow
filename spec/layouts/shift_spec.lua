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

require "mocked-keybow"
require "snippets/multibow"
local hwk = require("spec/hwkeys")
local mb = require("snippets/multibow")
local tt = require("spec/snippets/ticktock")

describe("SHIFT multibow keymap", function()

    inslit("installs the SHIFT keymap", function()
        -- Sanity check that there are no registered keymaps yet.
        assert.is.equal(#mb.registered_keymaps(), 0)

        local shift = require("layouts/shift")
        assert.is_not_nil(shift) -- we're going slightly over the top here...
        assert.is_not_nil(shift.keymap)

        -- SHIFT must register exactly two keymaps, a primary and a secondary one.
        local kms = mb.registered_keymaps()
        assert.is.equal(#kms, 2)
        for _, keymap in ipairs(kms) do
            if keymap == "shift" then
                assert.is_falsy(keymap.permanent)
                assert.is_falsy(keymap.secondary)
            elseif keymap == "shift-shifted" then
                assert.is_falsy(keymap.permanent)
                assert.is_true(keymap.secondary)
            end
        end
    end)

    inslit("accepts changes from default", function()
        local override = 42

        _G.shift = { KEY_SHIFT=override }
        local shift = require("layouts/shift")
        assert.is.equal(shift.KEY_SHIFT, override)
    end)

    describe("SHIFTY", function()

        -- ensure to get a fresh SHIFT layout instance each time we run
        -- an isolated, erm, insulated test.
        local shift

        before_each(function()
            shift = require("layouts/shift")
        end)

        after_each(function()
            mb.ungrab()
        end)

        inslit("short SHIFT tries to shift current keymap", function()
            stub(shift, "shift_secondary_keymap")

            hwk.press(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD/2)
            hwk.release(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD)
            assert.is.Nil(mb.grabber())
            assert.stub(shift.shift_secondary_keymap).was.called(1)
        end)

        inslit("long SHIFT grabs special SHIFT layout", function()
            stub(shift, "shift_secondary_keymap")

            hwk.press(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD*1.2)
            hwk.release(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD)
            assert.is.Not.Nil(mb.grabber())
            assert.stub(shift.shift_secondary_keymap).was.Not.called()
        end)

        inslit("short SHIFTs shifts to shifted test layout", function()
            local keymap = {
                name="test"
            }
            local keymap_shifted = {
                name="test-shifted",
                [0]={press=function(_) end}
            }
            keymap.shift_to = keymap_shifted
            keymap_shifted.shift_to = keymap
            mb.register_keymap(keymap)
            mb.register_keymap(keymap_shifted)
            assert.is.equal(mb.current_keymap, keymap)

            spy.on(mb, "activate_keymap")
            local s = stub(keymap_shifted[0], "press")

            hwk.press(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD/2)
            hwk.release(shift.KEY_SHIFT)
            tt.ticktock(10)
            assert.spy(mb.activate_keymap).was.called_with(keymap_shifted.name)
            assert.is.equal(mb.current_keymap, keymap_shifted)

            hwk.tap(0)
            assert.stub(s).was.called(1)

            hwk.tap(shift.KEY_SHIFT)
            assert.is.equal(mb.current_keymap, keymap)

            s:clear()
            hwk.tap(0)
            assert.stub(s).was_not.called()

            mb.activate_keymap:revert()
            s:revert()
        end)

        insl(function()
            describe("SHIFT specials", function()

                before_each(function()
                    hwk.press(shift.KEY_SHIFT)
                    tt.ticktock(shift.HOLD*1.2)
                    hwk.release(shift.KEY_SHIFT)
                    tt.ticktock(10)
                end)

                after_each(function()
                    mb.ungrab()
                end)

                it("cycles primary keymaps", function()
                    stub(mb, "cycle_primary_keymaps")

                    hwk.tap(shift.KEY_LAYOUT)
                    assert.stub(mb.cycle_primary_keymaps).was.called(1)

                    mb.cycle_primary_keymaps:revert()
                end)

                it("changes brightness", function()
                    stub(mb, "set_brightness")

                    hwk.tap(shift.KEY_BRIGHTNESS)
                    hwk.tap(shift.KEY_BRIGHTNESS)
                    assert.stub(mb.set_brightness).was.called(2)

                    mb.set_brightness:revert()
                end)

            end)
        end)

        inslit("cycles brightness", function()
            local s = spy.on(mb, "led")

            local len = #shift.BRIGHTNESS_LEVELS
            for i = 1, len do
                assert.equals(mb.brightness * 100, shift.BRIGHTNESS_LEVELS[i])
                -- enters SHIFT and check the brightness of brightness key...
                s:clear()
                hwk.press(shift.KEY_SHIFT)
                tt.ticktock(shift.HOLD*1.2)
                hwk.release(shift.KEY_SHIFT)
                tt.ticktock(10)
                assert.spy(s).was.called_with(
                    shift.KEY_BRIGHTNESS,
                    shift.next_brightness_color())
                -- cycles to next brightness
                hwk.tap(shift.KEY_BRIGHTNESS)
                hwk.press(shift.KEY_SHIFT)
                tt.ticktock(10)
                hwk.release(shift.KEY_SHIFT)
                tt.ticktock(10)
            end
            assert.equals(mb.brightness * 100, shift.BRIGHTNESS_LEVELS[1])
        end)

        inslit("glows in special SHIFT", function()
            local s= spy.on(shift, "glow")

            hwk.press(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD/2)
            hwk.release(shift.KEY_SHIFT)
            tt.ticktock(10)
            assert.spy(s).was.Not.called()

            hwk.press(shift.KEY_SHIFT)
            tt.ticktock(shift.HOLD+10)
            hwk.release(shift.KEY_SHIFT)
            tt.ticktock(1000)
            assert.spy(s).was.called.at.least(2)
        end)

    end)

end)
