#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git dart-sass libastal-meta npm curl libnotify ttf-material-symbols-variable-git ttf-jetbrains-mono-nerd ttf-rubik-vf pacman-contrib
install-optional-deps 'uwsm (for systems using uwsm)' 'yay (AUR package management)' 'fd (launcher file search)' 'wl-clipboard (clipboard support)' 'foot (opening stuff in terminal)'

set -l shell $CONFIG/shell

confirm-overwrite $shell
git clone 'https://github.com/caelestia-dots/shell.git' $shell

log 'Done.'
