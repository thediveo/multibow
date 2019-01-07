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
local hwk = require("spec/hwkeys")


describe("Kdenlive keymap", function()

    it("initializes", function()
        local mb = require("snippets/multibow")
        local k = require("layouts/kdenlive")
        assert.is.equal(k.keymap.name, mb.current_keymap.name)
 
        local kms = mb.registered_keymaps()
        assert.is.equal(2, #kms)
    end)

    describe("with setup", function()

        local mb, shift, k

        before_each(function()
            mb = require("snippets/multibow")
            shift = require("layouts/shift")
            k = require("layouts/kdenlive")
            _G.setup()
        end)

        inslit("colors its keys", function()
            for _, keymap in pairs(mb.registered_keymaps()) do
                if string.sub(keymap.name, 1, #"kdenlive") == "kdenlive" then
                    for keyno = 0, 11 do
                        local keydef = keymap[keyno]
                        if keydef then
                            assert.is_truthy(keydef.c)
                        end
                    end
                end
            end
        end)
    
        inslit("automatically un-shifts after key press", function()
            local some_key = shift.KEY_SHIFT ~= 0 and 0 or 1

            for round = 1, 2 do
                for round = 1, 2 do
                    assert.equals(k.keymap.name, mb.current_keymap.name)
                    hwk.tap(shift.KEY_SHIFT)
                    assert.equals(k.keymap_shifted.name, mb.current_keymap.name)
                    hwk.tap(some_key)
                    assert.equals(k.keymap.name, mb.current_keymap.name)
                end
                for round = 1, 2 do
                    hwk.tap(shift.KEY_SHIFT)
                    assert.equals(k.keymap_shifted.name, mb.current_keymap.name)
                    hwk.tap(shift.KEY_SHIFT)
                    assert.equals(k.keymap.name, mb.current_keymap.name)
                end
            end
        end)

        inslit("taps unshifted", function()
            local s = spy.on(mb, "tap")
            local sm = spy.on(keybow, "set_modifier")

            hwk.tap(k.KEY_PROJECT_BEGIN)
            assert.spy(s).was.called(1)
            assert.spy(sm).was_not.called()

            s:clear()
            hwk.tap(shift.KEY_SHIFT)
            assert.equals(k.keymap_shifted.name, mb.current_keymap.name)
            hwk.tap(k.KEY_CLIP_BEGIN)
            assert.spy(s).was.called(1)
            assert.spy(sm).was.called()
        end)

        inslit("taps", function()
            local s = spy.on(mb, "tap")

            hwk.tap(k.KEY_PLAY_AROUND_MOUSE)
            assert.spy(s).was.called()
            
            hwk.tap(shift.KEY_SHIFT)
            hwk.tap(k.KEY_PLAY_AROUND_MOUSE)
        end)

    end)

end)
