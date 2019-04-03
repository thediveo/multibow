
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
