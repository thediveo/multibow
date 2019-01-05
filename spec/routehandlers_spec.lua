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

describe("routehandlers", function()

    -- ensure to get a fresh multibow module instance each time we run
    -- an isolated test...
    local mb

    local spies = mock({
        prim_key_press=function(key) end,
        prim_key_release=function(key) end,
        prim_otherkey_press=function(key) end,
        prim_otherkey_release=function(key) end,
        perm_key_press=function(key) end,
        perm_key_release=function(key) end,
    })

    local primary_keymap = {
        name="test",
        [0]={press=spies.prim_key_press, release=spies.prim_key_release},
        [1]={press=spies.prim_otherkey_press, release=spies.prim_otherkey_release},
    }
    local permanent_keymap = {
        name="permanent",
        permanent=true,
        [0]={press=spies.perm_key_press, release=spies.perm_key_release}
    }

    before_each(function()
        require("keybow")
        mb = require("snippets/multibow")
        -- make sure to clear our spies
        for name, schlapphut in pairs(spies) do
            schlapphut:clear()
        end
    end)

    insl(function()
        it("defines all Keybow key handlers for routing", function()
            for keyno = 0, 11 do
                assert.is_function(_G[string.format("handle_key_%02d", keyno)])
            end
        end)
    end)

    insl(function()

        it("routes key press to primary keymap", function()
            assert.is_not_truthy(primary_keymap.permanent or primary_keymap.secondary)
            mb.register_keymap(primary_keymap)

            assert.spy(spies.prim_key_press).was_not.called() -- just a safety guard
            handle_key_00(true)
            assert.spy(spies.prim_key_press).was.called(1)
            assert.spy(spies.prim_key_press).was.called_with(0)
            assert.spy(spies.prim_key_release).was_not.called()
        end)

        it("routes key release to primary keymap", function()
            assert.spy(spies.prim_key_press).was_not.called() -- just a safety guard
            handle_key_00(false)
            assert.spy(spies.prim_key_press).was_not.called()
            assert.spy(spies.prim_key_release).was.called(1)
            assert.spy(spies.prim_key_release).was.called_with(0)
        end)

        it("routes with priority key press/release to permanent key", function()
            assert.is_truthy(permanent_keymap.permanent)
            assert.is_not_truthy(permanent_keymap.secondary)
            mb.register_keymap(permanent_keymap)

            handle_key_00(true)
            assert.spy(spies.perm_key_press).was.called(1)
            assert.spy(spies.perm_key_press).was.called_with(0)
            assert.spy(spies.perm_key_release).was_not.called()

            assert.spy(spies.prim_key_press).was_not_called()
        end)

        it("correctly routes key press to un-overlaid primary key 2", function()
            assert.spy(spies.prim_otherkey_press).was_not_called()
            handle_key_01(true)
            assert.spy(spies.prim_otherkey_press).was.called(1)
            assert.spy(spies.prim_otherkey_press).was.called_with(1)
        end)

    end)


end)
