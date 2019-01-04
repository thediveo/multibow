#!/bin/bash
# Installs the required libraries on Ubuntu ~18.10 LTS for Lua testing. 

#sudo apt-get remove lua*
sudo apt-get install --yes lua5.3 liblua5.3-dev
sudo update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3 10
sudo apt-get install --yes luarocks
sudo luarocks install busted
