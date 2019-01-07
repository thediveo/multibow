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
        for idx, keymap in ipairs(kms) do
            if keymap == "shift" then
                assert.is_falsy(keymap.permanent)
                assert.is_falsy(keymap.secondary)
            elseif keymap == "shift-shifted" then
                assert.is_falsy(keymap.permanent)
                assert.is_true(keymap.secondary)
            end
        end

        default_key_shift = shift.KEY_SHIFT
    end)

    inslit("accepts changes form default", function()
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

        inslit("SHIFT grabs", function()
            spy.on(mb, "grab")
            spy.on(mb, "ungrab")

            -- route in the SHIFT permanent keymap
            hwk.press(shift.KEY_SHIFT)
            assert.spy(mb.grab).was.called(1)
            assert.spy(mb.grab).was.called_with(shift.keymap_shifted.name)

            -- route in the shifted(!) SHIFT keymap, so this checks
            -- that we ungrab correctly
            mb.grab:clear()
            hwk.release(shift.KEY_SHIFT)
            assert.spy(mb.grab).was_not.called()
            assert.spy(mb.ungrab).was.called(1)

            mb.grab:revert()
            mb.ungrab:revert()
        end)

        inslit("only lonely SHIFT triggers shift and no dangling grabs", function()
            stub(shift, "shift_secondary_keymap")

            -- test that lonely SHIFT triggers...
            hwk.tap(shift.KEY_SHIFT)
            assert.is_nil(mb.grab_keymap)
            assert.stub(shift.shift_secondary_keymap).was.called(1)

            -- but that SHIFT followed by another function doesn't shift.
            shift.shift_secondary_keymap:clear()
            for idx, key in ipairs({
                shift.KEY_LAYOUT,
                shift.KEY_BRIGHTNESS
            }) do
                hwk.press(shift.KEY_SHIFT)
                hwk.tap(key)
                hwk.release(shift.KEY_SHIFT)
                assert.is_nil(mb.grab_keymap)
                assert.stub(shift.shift_secondary_keymap).was_not.called()
            end
        end)

        inslit("lonly SHIFTs shift around", function()
            local keymap = {
                name="test"
            }
            local keymap_shifted = {
                name="test-shifted",
                [0]={press=function(key) end}
            }
            keymap.shift_to = keymap_shifted
            keymap_shifted.shift_to = keymap
            mb.register_keymap(keymap)
            mb.register_keymap(keymap_shifted)
            assert.is.equal(mb.current_keymap, keymap)

            spy.on(mb, "activate_keymap")
            local s = stub(keymap_shifted[0], "press")

            hwk.tap(shift.KEY_SHIFT)
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
            describe("while SHIFTed", function()

                before_each(function()
                    hwk.press(shift.KEY_SHIFT)
                end)

                after_each(function()
                    hwk.release(shift.KEY_SHIFT)
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
                assert.spy(s).was.called_with(
                    shift.KEY_BRIGHTNESS, 
                    shift.next_brightness_color())
                -- cycles to next brightness
                hwk.tap(shift.KEY_BRIGHTNESS)
                hwk.release(shift.KEY_SHIFT)
            end
            assert.equals(mb.brightness * 100, shift.BRIGHTNESS_LEVELS[1])
        end)

    end)

end)
