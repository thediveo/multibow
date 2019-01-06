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

describe("routehandlers", function()

    -- ensure to get a fresh multibow module instance each time we run
    -- an isolated test...
    local mb

    local spies = mock({
        prim_key_press=function(key) end,
        prim_key_release=function(key) end,
        prim_otherkey_press=function(key) end,
        prim_otherkey_release=function(key) end,

        sec_key_press=function(key) end,
        sec_key_release=function(key) end,
        
        perm_key_press=function(key) end,
        perm_key_release=function(key) end,
        
        grab_key_press=function(key) end,
        grab_key_release=function(key) end,
    })

    local primary_keymap = {
        name="test",
        [0]={press=spies.prim_key_press, release=spies.prim_key_release},
        [1]={press=spies.prim_otherkey_press, release=spies.prim_otherkey_release},
    }
    local secondary_keymap = {
        name="test-secondary",
        secondary=true,
        [0]={press=spies.sec_key_press, release=spies.sec_key_release},
    }
    local permanent_keymap = {
        name="permanent",
        permanent=true,
        [0]={press=spies.perm_key_press, release=spies.perm_key_release}
    }
    local grab_keymap = {
        name="grab",
        [-1]={press=spies.grab_key_press, release=spies.grab_key_release},
        [0]={press=spies.grab_key_press, release=spies.grab_key_release}
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

        it("calls routing handler with correct key number", function()
            stub(mb, "route")
            for keyno = 0, 11 do
                mb.route:clear()
                hwk.press(keyno)
                assert.stub(mb.route).was.called(1)
                assert.stub(mb.route).was.called_with(keyno, true)
                mb.route:clear()
                hwk.release(keyno)
                assert.stub(mb.route).was.called(1)
                assert.stub(mb.route).was.called_with(keyno, false)
            end
            mb.route:revert()
        end)

    end)

    insl(function()

        it("doesn't fail for unroutable keys", function()
            hwk.press(0)
            hwk.release(0)
        end)

        -- start with secondary keymap only :)
        it("doesn't route a key press to a registered secondary keymap without activation", function()
            assert.is_not_truthy(secondary_keymap.permanent)
            assert.is_truthy(secondary_keymap.secondary)
            mb.register_keymap(secondary_keymap)

            assert.spy(spies.sec_key_press).was_not.called() -- just a safety guard
            hwk.press(0)
            assert.spy(spies.sec_key_press).was_not.called()
        end)

        it("routes key press to activated secondary keymap", function()
            mb.activate_keymap(secondary_keymap.name)

            hwk.press(0)
            assert.spy(spies.sec_key_press).was.called(1)
            assert.spy(spies.sec_key_press).was.called_with(0)
        end)

        -- throw in a primary keymap
        it("routes key press to primary keymap, but not to secondary", function()
            assert.is_not_truthy(primary_keymap.permanent or primary_keymap.secondary)
            mb.register_keymap(primary_keymap)
            mb.activate_keymap(primary_keymap.name)

            assert.spy(spies.prim_key_press).was_not.called() -- just a safety guard
            hwk.press(0)
            assert.spy(spies.prim_key_press).was.called(1)
            assert.spy(spies.prim_key_press).was.called_with(0)
            assert.spy(spies.prim_key_release).was_not.called()
        end)

        it("routes key release to primary keymap", function()
            assert.spy(spies.prim_key_press).was_not.called() -- just a safety guard
            hwk.release(0)
            assert.spy(spies.prim_key_press).was_not.called()
            assert.spy(spies.prim_key_release).was.called(1)
            assert.spy(spies.prim_key_release).was.called_with(0)
        end)

        -- adds a permanent keymap on top
        it("routes with priority key press/release to permanent key", function()
            assert.is_truthy(permanent_keymap.permanent)
            assert.is_not_truthy(permanent_keymap.secondary)
            mb.register_keymap(permanent_keymap)

            hwk.press(0)
            assert.spy(spies.perm_key_press).was.called(1)
            assert.spy(spies.perm_key_press).was.called_with(0)
            assert.spy(spies.perm_key_release).was_not.called()

            assert.spy(spies.prim_key_press).was_not_called()
        end)

        it("correctly routes key press to un-overlaid primary key 2", function()
            assert.spy(spies.prim_otherkey_press).was_not_called()
            hwk.press(1)
            assert.spy(spies.prim_otherkey_press).was.called(1)
            assert.spy(spies.prim_otherkey_press).was.called_with(1)
        end)

        -- and finally adds a grab keymap, what a mess!
        it("routes to grab keymap", function()
            mb.register_keymap(grab_keymap)
            mb.grab(grab_keymap.name)

            -- grab routes to grab handler *AND* grab any handler
            assert.spy(spies.grab_key_press).was.called(0)
            hwk.press(0)
            -- remember: this grab has an "any" handler
            assert.spy(spies.grab_key_press).was.called(2)
            assert.spy(spies.grab_key_press).was.called_with(0)

            spies.grab_key_press:clear()
            hwk.press(1)
            assert.spy(spies.grab_key_press).was.called(1)
            assert.spy(spies.grab_key_press).was.called_with(1)

            spies.grab_key_press:clear()
            mb.ungrab()
            hwk.press(0)
            assert.spy(spies.grab_key_press).was.called(0)
            assert.spy(spies.perm_key_press).was.called(1)
            assert.spy(spies.prim_key_press).was.called(0)
        end)

    end)

end)
