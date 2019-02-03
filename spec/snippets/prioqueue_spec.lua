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

local pq = require("snippets/mb/prioqueue")

describe("prioqueue", function()

    it("adds and peeks", function()
        local q = pq.new()
        q:add(200, "foo")
        q:add(100, "bar1")
        q:add(300, "zoo")
        q:add(100, "bar2")

        assert.is.equal(4, q.size)

        local p, v = q:peek()
        assert.is.same({100, "bar1"}, {p, v})

        p, v = q:remove()
        assert.is.same({100, "bar1"}, {p, v})
        p, v = q:remove()
        assert.is.same({100, "bar2"}, {p, v})
        p, v = q:remove()
        assert.is.same({200, "foo"}, {p, v})
        p, v = q:remove()
        assert.is.same({300, "zoo"}, {p, v})

        p, v = q:peek()
        assert.is.falsy(p)
        assert.is.falsy(v)
    end)

end)
