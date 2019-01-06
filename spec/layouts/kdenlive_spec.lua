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
local hwk = require("spec/hwkeys")


describe("Kdenlive keymap", function()

    it("...", function()
        local mb = require("snippets/multibow")
        local k = require("layouts/kdenlive")
        assert.is.equal(k.keymap.name, mb.current_keymap.name)
 
        local kms = mb.registered_keymaps()
        assert.is.equal(2, #kms)
    end)

    describe("with setup", function()

        local hwk, mb, k

        before_each(function()
            mb = require("snippets/multibow")
            require("layouts/shift")
            k = require("layouts/kdenlive")
            _G.setup()
        end)

        inslit("", function()
            assert.is.equal(k.keymap.name, mb.current_keymap.name)
        end)

    end)

end)
