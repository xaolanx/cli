#!/bin/fish

set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME/caelestia || set -l config ~/.config/caelestia
set -l dist $config/scripts

git clone https://github.com/caelestia-dots/scripts.git $dist
mkdir -p ~/.local/bin
ln -s $dist/main.fish ~/.local/bin/caelestia
