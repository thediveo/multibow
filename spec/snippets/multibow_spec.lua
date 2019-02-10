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

describe("multibow", function()

    -- ensure to get a fresh multibow module instance each time we run
    -- an isolated, nope, insulated test...
    local mb

    before_each(function()
        require("keybow")
        mb = require("snippets/multibow")
    end)

    inslit("sets up multibow, activates lights", function()
        local s = spy.on(_G, "setup")
        local al = spy.on(mb, "activate_leds")

        _G.setup()
        assert.spy(s).was.called(1)
        assert.spy(al).was.called(1)

        s:revert()
        al:revert()
    end)

    inslit("has more keys", function()
        assert.is_not_nil(keybow.F13)
        assert.is.equal(0x68, keybow.F13)
    end)

end)
