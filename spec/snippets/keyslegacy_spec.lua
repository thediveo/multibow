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
local mb = require("snippets/multibow")
local tt = require("spec/snippets/ticktock")

describe("legacy multibow key API", function()

    local tap = spy.on(keybow, "set_key")
    local mod = spy.on(keybow, "set_modifier")

    before_each(function()
        tap:clear()
        mod:clear()
    end)

    it("taps a plain honest key", function()
        mb.tap("x")
        tt.ticktock(100)
        assert.spy(tap).was.called(2*1)
        assert.spy(tap).was.called.With("x", keybow.KEY_DOWN)
        assert.spy(tap).was.called.With("x", keybow.KEY_UP)
        assert.spy(mod).was.Not.called()
    end)

    it("taps a plain honest key", function()
        mb.tap("x", keybow.LEFT_CTRL, keybow.LEFT_SHIFT)
        tt.ticktock(100)
        assert.spy(tap).was.called(2*1)
        assert.spy(mod).was.called(4)
        for _, ud in pairs({keybow.KEY_DOWN, keybow.KEY_UP}) do
            assert.spy(mod).was.called.With(keybow.LEFT_CTRL, ud)
            assert.spy(mod).was.called.With(keybow.LEFT_SHIFT, ud)
        end
    end)

    it("taps the same key repeatedly", function()
        mb.tap_times("x", 3)
        tt.ticktock(100)
        assert.spy(tap).was.called(2*3)
        assert.spy(tap).was.called.With("x", keybow.KEY_DOWN)
        assert.spy(tap).was.called.With("x", keybow.KEY_UP)
    end)

    it("taps the same key repeatedly with modifiers", function()
        mb.tap_times("x", 3, keybow.LEFT_CTRL)
        tt.ticktock(100)
        assert.spy(tap).was.called(2*3)
        assert.spy(tap).was.called.With("x", keybow.KEY_DOWN)
        assert.spy(tap).was.called.With("x", keybow.KEY_UP)
        assert.spy(mod).was.called(2)
        for _, ud in pairs({keybow.KEY_DOWN, keybow.KEY_UP}) do
            assert.spy(mod).was.called_with(keybow.LEFT_CTRL, ud)
        end
    end)

end)
