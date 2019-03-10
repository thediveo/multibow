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

describe("multibow keys", function()

    local tap = spy.on(keybow, "tap_key")
    local mod = spy.on(keybow, "set_modifier")

    before_each(function()
        tap:clear()
        mod:clear()
    end)

    it("taps a plain honest key", function()
        mb.tap("x")
        assert.spy(tap).was.called(1)
        assert.spy(tap).was.called_with("x")
        assert.spy(mod).was_not.called()
    end)

    it("taps a plain honest key", function()
        mb.tap("x", keybow.LEFT_CTRL, keybow.LEFT_SHIFT)
        assert.spy(tap).was.called(1)
        assert.spy(mod).was.called(4)
        for _, ud in pairs({keybow.KEY_DOWN, keybow.KEY_UP}) do
            assert.spy(mod).was.called_with(keybow.LEFT_CTRL, ud)
            assert.spy(mod).was.called_with(keybow.LEFT_SHIFT, ud)
        end
    end)

    it("taps the same key repeatedly", function()
        mb.tap_times("x", 3)
        assert.spy(tap).was.called(3)
        assert.spy(tap).was.called_with("x")
    end)

    it("taps the same key repeatedly with modifiers", function()
        mb.tap_times("x", 3, keybow.LEFT_CTRL)
        assert.spy(tap).was.called(3)
        assert.spy(tap).was.called_with("x")
        assert.spy(mod).was.called(2)
        for _, ud in pairs({keybow.KEY_DOWN, keybow.KEY_UP}) do
            assert.spy(mod).was.called_with(keybow.LEFT_CTRL, ud)
        end
    end)

end)

describe("key chaining operations", function()

    local tt = require("spec/snippets/ticktock")

    -- Ensure that there are no snafu'd tick jobs present at the begin of each
    -- new test, remaining from a previous (failed) test.
    before_each(function()
        mb.tq:clear()
    end)

    it("mb handles non-existing fields correctly", function()
        assert.is.Nil(mb.keys.foo)
    end)

    it("gets fresh key chains each time", function()
        local kc1 = mb.keys
        local kc2 = mb.keys
        assert.are.Not.equal(kc1, kc2)
    end)

    it("taps string keys", function()
        local s = spy.on(mb._keys, "op_tap")
        local t = spy.on(keybow, "set_key")
        mb.keys.tap("abc").tap("def")
        assert.spy(s).was.called(2)
        assert.spy(t).was.called(0)
        tt.ticktock(200)
        -- tap = press + release
        assert.spy(t).was.called(2*(3+3))
    end)

    it("taps ENTER key", function()
        local t = spy.on(keybow, "set_key")
        mb.keys.tap(keybow.ENTER)
        tt.ticktock(100)
        assert.spy(t).was.called(2)
        assert.spy(t).was.called.With(keybow.ENTER, keybow.KEY_DOWN)
        assert.spy(t).was.called.With(keybow.ENTER, keybow.KEY_UP)
    end)

    it("modifies keys", function()
        local t = spy.on(keybow, "set_key")
        local m = spy.on(keybow, "set_modifier")
        mb.keys.mod(keybow.LEFT_SHIFT, keybow.LEFT_CTRL).tap("abc")
        tt.ticktock(200)
        assert.spy(m).was.called(4)
        assert.spy(m).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_DOWN)
        assert.spy(m).was.called.With(keybow.LEFT_CTRL, keybow.KEY_DOWN)
        assert.spy(m).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_UP)
        assert.spy(m).was.called.With(keybow.LEFT_CTRL, keybow.KEY_UP)
        assert.spy(t).was.called(2*3)
    end)

    it("repeats keys", function()
        local s = spy.on(keybow, "set_key")
        mb.keys.times(3).tap("a") -- .tap("d")
        assert.spy(s).was.called(0)
        tt.ticktock(300)
        assert.spy(s).was.called(3*2*(1+0))
    end)

    it("fin ends repeating block", function()
        local s = spy.on(keybow, "set_key")
        mb.keys.times(2).tap("a").fin().tap("b")
        assert.spy(s).was.called(0)
        tt.ticktock(300)
        assert.spy(s).was.called(2*2*1+2*1)
    end)

end)

