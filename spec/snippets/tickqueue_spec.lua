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
local tq = require("snippets/mb/tickqueue")

local now = 0
local process = function(q, ms)
    local delta = 10
    local start = now
    for passed = delta,ms,delta do
        now = start + passed
        q:process(now)
    end
end

local El = {}
El.__index = El

function El:new(stub, times, delay) -- luacheck: ignore 212/self
    times = times or 0
    delay = delay or 0
    return setmetatable({
        stub=stub,
        times=times,
        delay=delay
    }, El)
end

-- luacheck: ignore 212/t
function El:process(t)
    if self.stub then self.stub() end
    self.times = self.times - 1
    return self.times > 0 and self.delay or -1
end

describe("ticking queue", function()

    it("processes a single entry with initial delay the expected number of times", function()
        local q = tq:new()
        local s = stub.new()
        q:add(El:new(s, 2), 20)

        process(q, 10)
        assert.stub(s).was.Not.called()

        process(q, 50)
        assert.stub(s).was.called(2)
    end)

    it("processes a single entry with intermediate delays", function()
        local q = tq:new()
        local s = stub.new()
        q:add(El:new(s, 2, 20), 0)

        process(q, 10)
        assert.stub(s).was.called()
        assert.is.Not.Nil(q.head) -- element still in queue

        s:clear()
        process(q, 10)
        assert.stub(s).was.Not.called()
        assert.is.Not.Nil(q.head) -- element still in queue

        s:clear()
        process(q, 20)
        assert.stub(s).was.called()
        assert.is.Nil(q.head) -- element now gone for good...
    end)

    it("processes multiple entries with intermediate delay", function()
        local q = tq:new()
        local s = stub.new()
        q:add(El:new())
        q:add(El:new(s), 20)

        process(q, 10)
        assert.stub(s).was.Not.called()
        process(q, 10)
        assert.stub(s).was.Not.called()
        process(q, 50)
        assert.stub(s).was.called()
    end)

end)
