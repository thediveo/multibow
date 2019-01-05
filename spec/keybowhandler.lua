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

kbh = {} -- module

-- Convenience: returns the name of a Keybow key handler function.
function kbh.handler_name(keyno)
    return string.format("handle_key_%02d", keyno)
end

-- Convenience: calls Keybow key handler by key number instead of name.
function kbh.handle_key(keyno, pressed)
    _G[kbh.handler_name(keyno)](pressed)
end

-- Convenience: taps a Keybow key, triggering the corresponding key handler
-- twice.
function kbh.tap(keyno)
    local h = _G[kbh.handler_name(keyno)]
    h(true)
    h(false)
end

return kbh -- module
