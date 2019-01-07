-- Part of Multibow

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


mb.MIN_BRIGHTNESS = mb.MIN_BRIGHTNESS or 0.1

-- Default LED brightness in the [0.1..1] range.
mb.brightness = 1

-- Sets the Keybow key LEDs maximum brightness, in the range [0.1..1] or
-- [10..100] (percent). The minim brightness is clamped on purpose to avoid
-- unlit LEDs. The lower clamp defaults to mb.MIN_BRIGHTNESS.
function mb.set_brightness(brightness)
    brightness = brightness > 1.0 and brightness / 100 or brightness
    if brightness < mb.MIN_BRIGHTNESS then brightness = mb.MIN_BRIGHTNESS end
    if brightness > 1 then brightness = 1 end
    mb.brightness = brightness
    mb.activate_leds()
end

-- Cycles through a list of brightness values, always taking the first
-- value and modifying the list by cycling it. Brightness values can be
-- either [0..1] or [0..100] (that is, percent)
function mb.cycle_brightness(brightnesses)
    local brightness = table.remove(brightnesses, 1)
    table.insert(brightnesses, brightness)
    mb.set_brightness(brightness)
    return brightnesses
end

-- Sets key LED to specific color, taking brightness into consideration.
-- The color is a triple (table) with the elements r, g, and b. Each color
-- component is in the range [0..1].
function mb.led(keyno, color)
    if color then
        local b = mb.brightness * 255
        keybow.set_pixel(keyno, color.r * b, color.g * b, color.b * b)
    else
        keybow.set_pixel(keyno, 0, 0, 0)
    end
  end
  
-- Restores Keybow LEDs according to current keymap and the permanent keymaps.
function mb.activate_leds()
    keybow.clear_lights()
    -- if a grab is in place then it takes absolute priority
    if mb.grab_keymap then
          mb.activate_keymap_leds(mb.grab_keymap)
    else
        -- first update LEDs for the current keymap...
        if mb.current_keymap ~= nil then
            mb.activate_keymap_leds(mb.current_keymap)
        end
        -- ...then update LEDs from permanent keymap(s), as this ensures that
        -- the permanent keymaps take precedence.
        for name, keymap in pairs(mb.keymaps) do
            if keymap.permanent then
            mb.activate_keymap_leds(keymap)
            end
        end
    end
end
  
-- Helper function that iterates over all keymap elements but skipping non-key
-- bindings.
function mb.activate_keymap_leds(keymap)
    for keyno, keydef in pairs(keymap) do
        -- Only iterates over keys, skipping any other keymap definitions.
        if type(keyno) == "number" and keydef.c then
            local color = type(keydef.c) == "function" and keydef.c() or keydef.c
            mb.led(keyno, color)
        end
    end
end
  
