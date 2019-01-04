require "keybow"

function keybow.set_pixel(pix, r, g, b)
  -- print("set_pixel " .. pix .. "(" .. r .. "," .. g .. "," .. b .. ")")
end

function keybow.auto_lights(onoff)
  -- print("auto_lights", onoff)
end

function keybow.clear_lights()
  -- print("clear_lights")
end

function keybow.tap_key(key)
  print("tap_key " .. tostring(key))
end

function keybow.set_modifier(mod, key)
  print("set_modifier " .. mod .. "," .. tostring(key))
end

require "keys"
setup()
