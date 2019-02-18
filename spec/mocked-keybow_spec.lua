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

-- luacheck: globals keybow.no_delay
require("mocked-keybow")

describe("Mocked Keybow API", function()

    local sock=require("socket")

    local sleep = function(time, factor, sf, on)
        local old = keybow.no_delay
        keybow.no_delay = not on
        local start = sock.gettime()
        sf(time)
        local delay = (sock.gettime() - start) * factor
        keybow.no_delay = old
        return delay
    end

    it("delays ms or not", function()
        assert.is.True(sleep(10, 1000, keybow.sleep, true) >= 10)
        assert.is.True(sleep(10, 1000, keybow.sleep, false) < 10)
    end)

    it("delays us or not", function()
        -- work around certain VM+system combinations being too unreliable for
        -- measuring in the us range, so we try several times and only fail in
        -- case the test fails for every attempt.
        local rounds = 20
        local fails = 0
        for _ = 1, rounds, 1 do
            if not (sleep(10, 1000*1000, keybow.usleep, true) >= 10) then
                fails = fails + 1
            elseif not (sleep(10, 1000*1000, keybow.usleep, false) < 10) then
                fails = fails + 1
            end
            -- assert.is.True(sleep(10, 1000*1000, keybow.usleep, true) >= 10)
            -- assert.is.True(sleep(10, 1000*1000, keybow.usleep, false) < 10)
        end
        assert.is.True(fails < rounds)
    end)

end)
