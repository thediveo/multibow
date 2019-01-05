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

local kbh = require("spec/keybowhandler")

describe("Keybow keyhandler", function()

    it("returns proper Keybow handler name", function()
        assert.equals(kbh.handler_name(0), "handle_key_00")
    end)

    it("calls correct Keybow key handler", function()
        stub(_G, "handle_key_00")
        stub(_G, "handle_key_01")

        kbh.handle_key(0, true)
        assert.stub(handle_key_00).was.called(1)
        assert.stub(handle_key_00).was.called_with(true)
        assert.stub(handle_key_01).was_not.called()

        handle_key_00:revert()
        handle_key_01:revert()
    end)

    describe("wrapped Keybow key handler 00", function()

        local old
        local seq

        before_each(function()
            old = _G.handle_key_00
            seq = {}
            _G.handle_key_00 = function(pressed)
                table.insert(seq, pressed)
            end
        end)

        after_each(function()
            _G.handle_key_00 = old
        end)

        it("taps Keybow key handlers", function()
            kbh.tap(0)
            assert.equals(#seq, 2)
            assert.same(seq, {true, false})
        end)
    
    end)

end)
