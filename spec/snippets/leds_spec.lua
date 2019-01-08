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
local mb = require("snippets/multibow")

describe("multibow LEDs", function()

    it("controls brightness", function()
        mb.set_brightness(0.5)
        assert.equals(0.5, mb.brightness)

        mb.set_brightness(1.0)
        assert.equals(1.0, mb.brightness)

        mb.set_brightness(0)
        assert.equals(mb.MIN_BRIGHTNESS, mb.brightness)

        mb.set_brightness(20)
        assert.equals(0.2, mb.brightness)
    end)

    it("cycles brightness", function()
        local f = function(b, scale)
            local copy = table.pack(table.unpack(b))
            local len = #b
            for i = 1, len do
                mb.cycle_brightness(copy)
                assert.equals(b[i], mb.brightness * scale)
            end
        end

        f({ 0.7, 1.0, 0.4 }, 1)
        f({ 70, 100, 40 }, 100)
    end)

    inslit("accepts LED color functions in keymaps", function()
        local s = spy.on(mb, "led")
        local km = {
            name="test",
            [0]={c={r=0, g=1, b=0}},
            [1]={c=function() return {r=1, g=1, b=1} end}
        }

        mb.activate_keymap_leds(km)
        assert.spy(s).was.called(2)
        assert.spy(s).was.called_with(0, {r=0, g=1, b=0})
        assert.spy(s).was.called_with(1, {r=1, g=1, b=1})
    end)

end)
