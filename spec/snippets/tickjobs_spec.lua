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

describe("tick jobs", function()

    local tt = require("spec/snippets/ticktock")

    -- Ensure that there are no snafu'd tick jobs present at the begin of each
    -- new test, remaining from a previous (failed) test.
    before_each(function()
        mb.tq:clear()
    end)

    it("mapper", function()
        local s = stub.new()
        mb.tq:add(mb.TickJobMapper:new(s, 1, 2, 3), 20)
        local t = stub.new()
        mb.tq:add(mb.TickJobMapper:new(t, 42), 100)

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
        assert.stub(t).was.Not.called()

        -- should now process all elements of tm2, too.
        tt.ticktock(100)
        assert.stub(s).was.Not.called()
        assert.stub(t).was.called(1)
        assert.stub(t).was.called.With(42)
    end)

    it("mapper with two functions", function()
        local s = stub.new()
        mb.tq:add(mb.TickJobMapper:new({s, s}, 1, 2, 3), 0)
        tt.ticktock(100)
        assert.stub(s).was.called(2*3)
    end)

    it("repeater", function()
        local s = stub.new()
        local tj = mb.TickJobMapper:new(s, 42)
        mb.tq:add(mb.TickJobRepeater:new(tj, 2, 20))

        tt.ticktock(10)
        assert.stub(s).was.called(1)

        -- checks that the spacing (wait time between iterations) gets
        -- correctly carried out.
        s:clear()
        tt.ticktock(10)
        assert.stub(s).was.Not.called()

        s:clear()
        tt.ticktock(10)
        assert.stub(s).was.called(1)
    end)

    it("repeats a repeater", function()
        local s = stub.new()
        local tj = mb.TickJobMapper:new(s, 42)
        local rtj = mb.TickJobRepeater:new(tj, 2)
        mb.tq:add(mb.TickJobRepeater:new(rtj, 2))

        tt.ticktock(50)
        assert.stub(s).was.called(4)
    end)

    it("enclosure", function()
        local s = stub.new()
        local before = stub.new()
        local after = stub.new()
        local tj = mb.TickJobMapper:new(s, 42)
        mb.tq:add(mb.TickJobEncloser:new(tj, before, after, 4242, 4243))

        tt.ticktock(50)
        assert.spy(before).was.called(2)
        assert.spy(before).was.called.With(4242)
        assert.spy(before).was.called.With(4243)

        assert.spy(s).was.called(1)
        assert.spy(s).was.called.With(42)

        assert.spy(after).was.called(2)
        assert.spy(after).was.called.With(4242)
        assert.spy(after).was.called.With(4243)
    end)
    
    it("sequence", function()
        local s = stub.new()
        local seq = mb.TickJobSequencer:new()
        local m1 = mb.TickJobMapper:new(s, 42, 43)
        m1.afterms = 20
        seq:add(m1)
        local m2 = mb.TickJobMapper:new(s, 44)
        m2.afterms = 20
        seq:add(m2)
        mb.tq:add(seq)

        tt.ticktock(10)
        assert.spy(s).was.Not.called()

        tt.ticktock(30)
        assert.spy(s).was.called(2)

        tt.ticktock(10)
        assert.spy(s).was.called(2)

        tt.ticktock(30)
        assert.spy(s).was.called(3)
    end)

end)
