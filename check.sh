#!/bin/bash
echo "testing..."
./env.sh busted
echo "linting..."
./env.sh luacheck -q ./sdcard ./spec
