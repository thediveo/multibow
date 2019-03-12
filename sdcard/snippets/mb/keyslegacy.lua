-- Multibow internal "module" implementing legacy API convenience functions
-- for sending key presses to the USB host to which the Keybow device is
-- connected to.

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

-- luacheck: globals mb

-- Legacy keystroke "classic" API support ... to be removed in the near
-- future.

-- Sends a single key tap to the USB host, optionally with modifier keys, such
-- as SHIFT (keybow.LEFT_SHIFT), CTRL (keybow.LEFT_CTRL), et cetera. The "key"
-- parameter can be a string or a Keybow key code, such as keybow.HOME, et
-- cetera.
function mb.tap(key, ...)
    if select("#", ...) > 0 then
        mb.keys.mod(...).tap(key)
    else
        mb.keys.tap(key)
    end
end

-- Taps the same key multiple times, optionally with modifier keys; however,
-- for optimization, these modifiers are only pressed once before the tap
-- sequence, and only released once after all taps.
function mb.tap_times(key, x, ...)
    if select("#", ...) > 0 then
        mb.keys.mod(...).times(x).tap(key)
    else
        mb.keys.times(x).tap(key)
    end
end
