#!/bin/bash
hascmd() {
    command -v "$1" >/dev/null
}
if ! hascmd busted || ! hascmd luacheck ; then
    echo "missing busted TDD library and luacheck Lua static source code checker; trying to install..."
    bash ./setup-tests.sh
fi
echo "testing..."
busted
echo "linting..."
luacheck -q ./sdcard ./spec
