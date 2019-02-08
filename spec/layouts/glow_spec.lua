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
local tt = require("spec/snippets/ticktock")

describe("template multibow keymap", function()

    local mb = require("snippets/multibow")
    local glow

    before_each(function()
        require("layouts/empty")
        glow = require("layouts/glow")
    end)

    inslit("installs a glow, empty primary keymaps", function()
        assert.is_not_nil(glow) -- we're going over the top here...
        assert.is_not_nil(glow.keymap) -- ...even more so.

        -- empty must be registered first, glow second.
        local kms = mb.registered_keymaps()
        assert.is.equal(2, #kms)
        local keymap = nil
        for _, km in ipairs(kms) do
            if km.name == "glow" then
                keymap = km
            end
        end
        assert.is_not_nil(keymap)
        assert.is_falsy(keymap.permanent)
        assert.is_falsy(keymap.secondary)
        assert.is.equal(keymap.name, "glow")
    end)


    inslit("calls activation handler", function()
        local act = spy.on(glow.keymap, "activate")
        local deact = spy.on(glow.keymap, "deactivate")
        local led = spy.on(glow, "led")

        mb.activate_keymap("glow")
        assert.spy(act).was.called(1)
        assert.spy(deact).was_not.called()

        tt.ticktock(100)
        assert.spy(led).was.called(10)

        act:clear()
        mb.activate_keymap("empty")
        assert.spy(act).was_not.called()
        assert.spy(deact).was.called(1)
    end)

end)
