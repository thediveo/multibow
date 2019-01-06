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

    inslit("adds permanent keyboard layout, but doesn't activate it", function()
        local permkm = {
            name="permanent",
            permanent=true
        }
        assert.is_nil(mb.keymaps["permanent"])
        mb.register_keymap(permkm)
        assert.is.equal(mb.keymaps["permanent"], permkm)
        assert.is_nil(mb.current_keymap)
    end)

    inslit("checks multibow module is fresh again", function()
        assert.is_nil(mb.keymaps["permanent"])
    end)

    inslit("adds permanent, then two primary layouts, activates only first primary layout", function()
        local permkm = {
            name="permanent",
            permanent=true
        }
        mb.register_keymap(permkm)
        local prim1km = { name="bavaria-one" }
        local prim2km = { name="primary-two" }
        mb.register_keymap(prim1km)
        mb.register_keymap(prim2km)
        assert.is.equal(prim1km, mb.current_keymap)
    end)

    inslit("sequence of primary keymaps is in registration order", function()
        local prim1km = { name="last" }
        local prim2km = { name="first" }
        mb.register_keymap(prim1km)
        mb.register_keymap(prim2km)
        assert.is.same(mb.registered_primary_keymaps(), {prim1km, prim2km})
    end)

    inslit("adds secondary, then primary layout, activates only primary layout", function()
        local primkm = { name="berlin" }
        local seckm = { name="munich", secondary=true }
        mb.register_keymap(seckm)
        mb.register_keymap(primkm)
        assert.is.equal(primkm, mb.current_keymap)
    end)

    inslit("cycles primary keymaps based on primary-secondary names substring match", function()
        -- on purpose, the names of the primary keymaps are in reverse lexical order,
        -- to make sure that cycling follows the registration order, but not the
        -- name order.
        local prim1km = { name= "last" }
        local sec1km = { name="last-shift", secondary=true }
        local sec2km = { name="xlast-shift", secondary=true}
        local prim2km = { name= "first" }
        mb.register_keymap(prim1km)
        mb.register_keymap(prim2km)
        mb.register_keymap(sec1km)
        mb.register_keymap(sec2km)
        assert.is.equal(4, #mb.registered_keymaps())
        assert.is.same(mb.registered_primary_keymaps(), {prim1km, prim2km})

        -- cycles from secondary to next primary
        mb.activate_keymap(sec1km.name)
        mb.cycle_primary_keymaps()
        assert.is.equal(prim2km.name, mb.current_keymap.name)
        -- cycles from last primary to first primary
        mb.cycle_primary_keymaps()
        assert.is.equal(prim1km.name, mb.current_keymap.name)
        -- cannot cycle from misnamed secondary without shift_to
        mb.activate_keymap(sec2km.name)
        mb.cycle_primary_keymaps()
        assert.is.equal(sec2km.name, mb.current_keymap.name)
    end)

    inslit("cycles primary keymaps based on shift_to", function()
        -- on purpose, the names of the primary keymaps are in reverse lexical order,
        -- to make sure that cycling follows the registration order, but not the
        -- name order.
        local prim1km = { name= "last" }
        local sec1km = { name="last-shift", secondary=true, shift_to }
        prim1km.shift_to = sec1km
        local prim2km = { name= "first" }
        mb.register_keymap(prim1km)
        mb.register_keymap(prim2km)
        mb.register_keymap(sec1km)
        assert.is.same(mb.registered_primary_keymaps(), {prim1km, prim2km})

        -- cycles from secondary to next primary
        mb.activate_keymap(sec1km.name)
        mb.cycle_primary_keymaps()
        assert.is.equal(prim2km.name, mb.current_keymap.name)
        -- cycles from last primary to first primary
        mb.cycle_primary_keymaps()
        assert.is.equal(prim1km.name, mb.current_keymap.name)
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
