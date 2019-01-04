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
    -- an isolated test...
    local mb

    before_each(function()
        require("keybow")
        stub(keybow, "set_pixel")
        mb = require("snippets/multibow")
    end)

    insl(function()
        it("adds permanent keyboard layout, but doesn't activate it", function()
            local permkm = {
                name="permanent",
                permanent=true
            }
            assert.is_nil(mb.keymaps["permanent"])
            mb.register_keymap(permkm)
            assert.is.equal(mb.keymaps["permanent"], permkm)
            assert.is_nil(mb.current_keymap)
        end)
    end)

    insl(function()
        it("checks multibow module is fresh again", function()
            assert.is_nil(mb.keymaps["permanent"])
        end)
    end)

    insl(function()
        it("adds permanent, then two primary layouts, activates only first primary layout", function()
            local permkm = {
                name="permanent",
                permanent=true
            }
            mb.register_keymap(permkm)
            local prim1km = { name="bavaria-one" }
            local prim2km = { name="primary-two" }
            mb.register_keymap(prim1km)
            mb.register_keymap(prim2km)
            assert.is.equal(mb.current_keymap, prim1km)
        end)
    end)

    insl(function()
        it("adds secondary, then primary layout, activates only primary layout", function()
            local primkm = { name="berlin" }
            local seckm = { name="munich", secondary=true }
            mb.register_keymap(seckm)
            mb.register_keymap(primkm)
            assert.is.equal(mb.current_keymap, primkm)
        end)
    end)

    insl(function()
        it("sets up multibow, activates lights", function()
            local s = spy.on(_G, "setup")
            _G.setup()
            assert.spy(s).was.called(1)

            local al = spy.on(mb, "activate_leds")
            _G.setup()
            assert.spy(al).was.called(1)
        end)
    end)

end)
