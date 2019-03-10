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

describe("#ignore asynchronous keys", function()

    local tt = require("spec/snippets/ticktock")

    before_each(function()
        mb.tq:clear()
    end)

    it("#ignore map a function on a ticking element sequence", function()
        local s = stub.new()
        mb.send_mapped(20, s, 1, 2, 3)
        local t = stub.new()
        mb.send_mapped(100, t, 42)

        -- "empty tick", as the tick mapper is yet delayed...
        tt.ticktock(10)
        assert.stub(s).was.Not.called()

        -- should process all elements of tm1, but none of tm2...
        tt.ticktock(30)
        assert.stub(s).was.called(3)
        assert.stub(s).was.called.With(1)
        assert.stub(s).was.called.With(2)
        assert.stub(s).was.called.With(3)
        s:clear()
        tt.ticktock(20)
        assert.stub(s).was.called(0)
        assert.stub(t).was.Not.called()

        -- should now process all elements of tm2, too.
        tt.ticktock(100)
        assert.stub(s).was.Not.called()
        assert.stub(t).was.called(1)
        assert.stub(t).was.called.With(42)
    end)

    it("#ignore map two functions on ticking sequence", function()
        local s = stub.new()
        mb.send_mapped(0, {s, s}, 1, 2, 3)
        tt.ticktock(100)
        assert.stub(s).was.called(2*3)
    end)

    it("#ignore tick repeatedly", function()
        local s = stub.new()
        local kj = mb.KeyJobMapper:new(s, 42)
        mb.keys:add(mb.KeyJobRepeater:new(kj, 2, 20))

        tt.ticktock(10)
        assert.stub(s).was.called(1)

        s:clear()
        tt.ticktock(10)
        assert.stub(s).was.Not.called()

        s:clear()
        tt.ticktock(10)
        assert.stub(s).was.called(1)
    end)

    it("#ignore tick repeatedly**2", function()
        local s = stub.new()
        local kj = mb.KeyJobMapper:new(s, 42)
        local rkj = mb.KeyJobRepeater:new(kj, 2)
        mb.keys:add(mb.KeyJobRepeater:new(rkj, 2))

        tt.ticktock(50)
        assert.stub(s).was.called(4)
    end)

    it("#ignore tick modifiers", function()
        local s = spy.on(keybow, "set_modifier")
        mb.send_modifiers(0, keybow.KEY_DOWN, keybow.LEFT_CTRL, keybow.LEFT_SHIFT)

        tt.ticktock(50)
        assert.spy(s).was.called(2)
        assert.spy(s).was.called.With(keybow.LEFT_CTRL, keybow.KEY_DOWN)
        assert.spy(s).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_DOWN)
    end)

    it("#ignore tick keys in a string", function()
        local sm = spy.on(keybow, "set_modifier")
        local sk = spy.on(keybow, "set_key")
        mb.send_keys(0, "abc", keybow.LEFT_CTRL, keybow.LEFT_SHIFT)

        tt.ticktock(100)
        -- note that the modifiers were pressed AND released by now...
        assert.spy(sm).was.called(4)
        assert.spy(sm).was.called.With(keybow.LEFT_CTRL, keybow.KEY_DOWN)
        assert.spy(sm).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_DOWN)
        assert.spy(sm).was.called.With(keybow.LEFT_CTRL, keybow.KEY_UP)
        assert.spy(sm).was.called.With(keybow.LEFT_SHIFT, keybow.KEY_UP)

        -- note that set_key needs to be called twice for each key tap.
        assert.spy(sk).was.called(2*3)
        assert.spy(sk).was.called.With("a", true)
        assert.spy(sk).was.called.With("a", false)
        assert.spy(sk).was.called.With("b", true)
        assert.spy(sk).was.called.With("b", false)
        assert.spy(sk).was.called.With("c", true)
        assert.spy(sk).was.called.With("c", false)
    end)

    it("#ignore tick keys in a table", function()
        local sk = spy.on(keybow, "set_key")
        mb.send_keys(0, {"a", keybow.ENTER, "c"})

        tt.ticktock(100)

        assert.spy(sk).was.called(2*3)
        assert.spy(sk).was.called.With("a", true)
        assert.spy(sk).was.called.With("a", false)
        assert.spy(sk).was.called.With(keybow.ENTER, true)
        assert.spy(sk).was.called.With(keybow.ENTER, false)
        assert.spy(sk).was.called.With("c", true)
        assert.spy(sk).was.called.With("c", false)
    end)

end)
