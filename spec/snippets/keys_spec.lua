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

describe("key chaining operations", function()

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

    it("shifts keys", function()
        local m = spy.on(keybow, "set_modifier")
        mb.keys.shift.tap("a")
        tt.ticktock(100)
        assert.spy(m).was.called(2)
        assert.spy(m).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_DOWN)
        assert.spy(m).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_UP)
    end)

    it("ctrls keys", function()
        local m = spy.on(keybow, "set_modifier")
        mb.keys.ctrl.tap("a")
        tt.ticktock(100)
        assert.spy(m).was.called(2)
        assert.spy(m).was.called.With(keybow.LEFT_CTRL, keybow.KEY_DOWN)
        assert.spy(m).was.called.With(keybow.LEFT_CTRL, keybow.KEY_UP)
    end)

    it("alts keys", function()
        local m = spy.on(keybow, "set_modifier")
        mb.keys.alt.tap("a")
        tt.ticktock(100)
        assert.spy(m).was.called(2)
        assert.spy(m).was.called.With(keybow.LEFT_ALT, keybow.KEY_DOWN)
        assert.spy(m).was.called.With(keybow.LEFT_ALT, keybow.KEY_UP)
    end)

    it("metas keys", function()
        local m = spy.on(keybow, "set_modifier")
        mb.keys.meta.tap("a")
        tt.ticktock(100)
        assert.spy(m).was.called(2)
        assert.spy(m).was.called.With(keybow.LEFT_META, keybow.KEY_DOWN)
        assert.spy(m).was.called.With(keybow.LEFT_META, keybow.KEY_UP)
    end)

    it("arrows around", function()
        local t = spy.on(keybow, "set_key")
        mb.keys.left.right.up.down()
        tt.ticktock(100)
        assert.spy(t).was.called(2*4)
        for _, arr in pairs({keybow.LEFT_ARROW, keybow.RIGHT_ARROW,
                             keybow.UP_ARROW, keybow.DOWN_ARROW}) do
            assert.spy(t).was.called_with(arr, keybow.KEY_DOWN)
        end
    end)

    it("accepts UPPerCAse OPerAtiONs", function()
        local t = spy.on(keybow, "set_key")
        mb.keys.End()
        tt.ticktock(100)
        assert.spy(t).was.called(2)
        assert.spy(t).was.called.with(keybow.END, keybow.KEY_DOWN)
        assert.spy(t).was.called.with(keybow.END, keybow.KEY_UP)
    end)

    it("repeats keys", function()
        local s = spy.on(keybow, "set_key")
        mb.keys.times(3).tap("abc")
        assert.spy(s).was.called(0)
        tt.ticktock(300)
        assert.spy(s).was.called(3*2*3)
    end)

    it("repeats key sequences", function()
        local s = spy.on(keybow, "set_key")
        mb.keys.times(3).tap("a").tap("bc").tap("d")
        assert.spy(s).was.called(0)
        tt.ticktock(400)
        assert.spy(s).was.called(3*2*(1+2+1))
    end)

    it("fin/done ends repeating sequence block", function()
        local s = spy.on(keybow, "set_key")
        mb.keys.times(2).tap("a").tap("b").done.tap("c")
        assert.spy(s).was.called(0)
        tt.ticktock(300)
        assert.spy(s).was.called(2*2*(1+1)+2*1)
    end)

    it("calls arg-less operations within chains", function()
        local s = spy.on(keybow, "set_key")
        mb.keys.times(2).tap("a").tap("b").fin.tap("c")
        tt.ticktock(300)
        assert.spy(s).was.called(2*2*(1+1)+2*1)
    end)

    it("surplus fin", function()
        mb.keys.fin()
    end)

    it("waits before operation", function()
        tt.ticktock(10) -- initialize tickerqueue time ... wtf?
        local s = spy.on(keybow, "set_key")
        mb.keys.wait(10).wait(10).tap("x")
        tt.ticktock(10)
        assert.spy(s).was.Not.called()
        tt.ticktock(50)
        assert.spy(s).was.called(2*1)
    end)

    it("spaces repeats", function()
        tt.ticktock(10) -- initialize tickerqueue time ... wtf?
        local s = spy.on(keybow, "set_key")
        mb.keys.times(2).space(50).tap("x")
        tt.ticktock(20)
        assert.spy(s).was.called(2*1)
        tt.ticktock(40)
        assert.spy(s).was.called(2*1)
        tt.ticktock(100)
        assert.spy(s).was.called(2*2)
    end)

end)
