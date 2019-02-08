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

describe("multibow timers", function()

    before_each(function()
        mb.now = 0
    end)

    it("ticks", function()
        assert.is.equal(mb.now, 0)
        tt.ticktock(100)
        assert.is.equal(mb.now, 100)
    end)

    it("triggers alarm at the right time", function()
        local trigger = spy.new(function() end)
        local timer = mb.after(100, trigger, 1, 2, 3)

        tt.ticktock(50)
        assert.spy(trigger).was_not.called()
        assert.is.truthy(timer:isarmed())
        tt.ticktock(200)
        assert.spy(trigger).was.called(1)
        assert.spy(trigger).was.called_with(1, 2, 3)
        assert.is.falsy(timer:isarmed())

        trigger:clear()
        mb.after(-1, trigger)
        tt.ticktock(100)
        assert.spy(trigger).was.called(1)
    end)

    it("triggers multiple alarms in correct order", function()
        local t1 = spy.new(function() end)
        local t2 = spy.new(function() end)
        mb.after(100, t2)
        mb.after(50, t1)

        tt.ticktock(60)
        assert.spy(t1).was.called(1)
        assert.spy(t2).was_not.called()

        t1:clear()
        tt.ticktock(50)
        assert.spy(t1).was_not.called()
        assert.spy(t2).was.called(1)
    end)

    it("cancels alarms", function()
        local trigger = spy.new(function() end)
        local timer = mb.after(100, trigger, 1, 2, 3)

        tt.ticktock(50)
        assert.is.truthy(timer:isarmed())
        timer:cancel()
        assert.is.falsy(timer:isarmed())
        tt.ticktock(60)
        assert.spy(trigger).was_not.called()

        timer:cancel()
        tt.ticktock(10)
        assert.spy(trigger).was_not.called()
    end)

    it("goes on, and on, and on...", function()
        local trigger = spy.new(function() end)
        local timer = mb.every(20, trigger, 1, 2, 3)

        tt.ticktock(50)
        assert.spy(trigger).was.called(2)
        assert.spy(trigger).was.called_with(1, 2, 3)

        trigger:clear()
        timer:cancel()
        tt.ticktock(50)
        assert.spy(trigger).was_not.called()
    end)

end)
