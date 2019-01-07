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

describe("template multibow keymap", function()

    local mb = require("snippets/multibow")
    local hwk = require("spec/hwkeys")
    local kmt = require("layouts/keymap-template")

    inslit("installs a single primary keymap", function()
        assert.is_not_nil(kmt) -- we're going over the top here...
        assert.is_not_nil(kmt.keymap) -- ...even more so.
        
        -- empty must register exactly one keymap, and it must be
        -- a primary keymap, not permanent or secondary.
        local kms = mb.registered_keymaps()
        assert.is.equal(1, #kms)
        local keymap = kms[1]
        assert.is_falsy(keymap.permanent)
        assert.is_falsy(keymap.secondary)
    end)


    inslit("calls press and release handlers", function()
        local mp = spy.on(kmt.keymap[1], "press")
        local mr = spy.on(kmt.keymap[2], "release")

        hwk.tap(1)
        assert.spy(mp).was.called(1)
        hwk.tap(2)
        assert.spy(mr).was.called(1)
    end)

end)
