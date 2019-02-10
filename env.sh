#!/bin/bash
#
# Checks for a local lua/luarocks/... environment, installing it if it is
# missing. If a command and arguments are specified, then this command is run
# from the environment.
#
# Copyright 2019 Harald Albrecht
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

VENV=./env
HEREROCKS=$VENV/hererocks.py

# Checks for a specific luarocks package, installing it if necessary.
rock() {
    luarocks list | grep -q $1
    if [ $? != 0 ]; then
        luarocks install $1
    fi
}

# Downloads the fine hererocks Lua/luarocks installation script if not already
# done so, then ensures to install Lua 5.3 and latest luarocks.
mkdir -p $VENV
if [ ! -f $VENV/hererocks.py ]; then
    wget https://raw.githubusercontent.com/mpeterv/hererocks/latest/hererocks.py -O $HEREROCKS
fi
if [ ! -f $VENV/bin/activate ]; then
    python3 $HEREROCKS $VENV -l5.3 -rlatest
fi

# Activate the Lua/luarocks environment, then check for required luarocks
# packages, and install the missing ones.
source $VENV/bin/activate
rock luasec
rock busted
rock luasocket
rock luacheck
rock cluacov

# Finally check if a command with args should be run from inside the Lua
# environment.
if [ -n "$1" ]; then
    CMD=$VENV/bin/$1
    shift
    $CMD "$@"
fi
