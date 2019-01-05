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

describe("empty multibow keymap", function()

    local mb = require("snippets/multibow")

    insl(function()
        it("installs a single empty primary keymap", function()
            -- Sanity check that there are no registered keymaps yet.
            assert.is.equal(#mb.registered_keymaps(), 0)
            
            local empty = require("layouts/empty")
            assert.is_not_nil(empty) -- we're going over the top here...
            assert.is_not_nil(empty.keymap) -- ...even more so.
            
            -- empty must register exactly one keymap, and it must be
            -- a primary keymap, not permanent or secondary.
            local kms = mb.registered_keymaps()
            assert.is.equal(#kms, 1)
            local keymap = kms[1]
            assert.is_falsy(keymap.permanent)
            assert.is_falsy(keymap.secondary)
        end)
    end)

end)
