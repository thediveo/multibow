
-- List of modifier levels in the keymaps, and their associated modifier key(s).
local keymap_levels = {
    {field='norm', mods=0},
    {field='shift', mods=1<<keybow.LEFT_SHIFT},
    {field='altgr', mods=1<<keybow.RIGHT_ALT},
    {field='altgrshift', mods=(1<<keybow.RIGHT_ALT)+(1<<keybow.LEFT_SHIFT)}
}

-- Calculates a map for quickly mapping glyphs to keycodes and modifier keys.
-- The map gets stored with a specific layout in its (new) "map" field. 
function create_map(layout)
    -- If we already built the translation map for this layout, then we don't
    -- need to rebuilt it. Done.
    if layout.map then return end
    local map = {}
    -- Scan through all modifier levels of the keyboard layout with all its keys
    -- in order to build a map for quickly translating individual glyphs into
    -- their USB keycodes and modifier(s).
    for _, kl in ipairs(keymap_levels) do
        field = kl.field
        mods = kl.mods
        for row = 1, 4 do
            for col, glyph in ipairs(layout[field][row]) do
                map[glyph] = {
                    keycode=kb.keycodes_layout[row][col],
                    mods=mods
                }
            end
        end
    end
    -- Store the freshly built map in the specific layout for later quick use.
    layout.map = map
end

function kb.set_layout(code)
    l = kb[code]
    if l then
        create_map(l)
        kb.layout = l
    end
end


-- Please note: since Lua hasn't really any Unicode support, despite fishy
-- claims to the contrary, we need to be careful when processing Unicode strings
-- (in UTF-8 encoding). Multibow users must encode their scripts in UTF-8. This
-- way, we can split such UTF-8 string correctly at glyph boundaries in order to
-- translate Unicode glyphs into their corresponding keystrokes, if available.
-- Plain ASCII wouldn't get us too far here when it comes to international
-- keyboards. Thus, we work with Unicode in UTF-8 encoding.
function kb.string_to_keycodes(s)
    -- See https://stackoverflow.com/a/13238257 for breaking an UTF-8 string
    -- down into its individual glyphs (also in UTF-8), thus breaking the Lua
    -- binary string at glyph boundaries. This assumes that we got valid UTF-8
    -- encoding at this point, which is a pretty safe bet.
    for glyph in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        -- translate glyph (iff known)
        keycode = kb.layout.map[glyph]
        if keycode then
            -- ...
        end
    end
end
