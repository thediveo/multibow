-- The USB keycodes based on key topology (US key topology). See also ch 10,
-- "Keyboard/Keypad Page (0x07)" in "USB Usage Tables", version 1.12,
-- https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf
--
-- These are the keycodes we need to send to the USB host. Host operating
-- systems will typically interpret the keycodes as topological keycodes
-- ... which will then undergo language layout-specific translation in the
-- host.
--
-- Important: for consistency with most international layouts, key #49 has been
-- moved from the right end of the second row (from top to bottom) to the first
-- position of the bottom-most row. Similarly, the non-US key #50 is included
-- and placed at the end of the third row.
kb.keycodes_layout = {
    {53, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 45, 46},
    {14, 26, 8, 21, 23, 28, 24, 12, 18, 19, 47, 48},
    {4, 22, 7, 9, 10, 11, 13, 14, 15, 51, 52, 50},
    {49, 29, 27, 6, 25, 5, 17, 16, 54, 55, 56},
}

-- US keyboard layout; please note that this is not the 100% true US layout, but
-- instead allows us to map glyphs to their corresponding USB "topological"
-- keycodes.
kb["us"] = {
    norm = {
        {"`","1","2","3","4","5","6","7","8","9","0","-","="},
        {"q","w","e","r","t","y","u","i","o","p","[","]"},
        {"a","s","d","f","g","h","j","k","l",";","'",""},
        {"\\","z","x","c","v","b","n","m",",",".","/"},
    },
    shift = {
        {"~","!","@","#","$","%","^","&","*","(",")","_","+"},
        {"Q","W","E","R","T","Y","U","I","O","P","{","}"},
        {"A","S","D","F","G","H","J","K","L",":","\"",""},
        {"|","Z","X","C","V","B","N","M","<",">","?"},
    },
    altgr = {
        {"","","","","","","","","","","","",""},
        {"","","","","","","","","","","","",""},
        {"","","","","","","","","","","",""},
        {"","","","","","","","","",""},
    },
    altgrshift = {
        {"","","","","","","","","","","","",""},
        {"","","","","","","","","","","","",""},
        {"","","","","","","","","","","",""},
        {"","","","","","","","","",""},
    }
}
