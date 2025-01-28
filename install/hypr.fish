#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git uwsm hyprland-git hyprpaper-git hyprlock-git hypridle-git polkit-gnome gnome-keyring wl-clipboard wireplumber
install-optional-deps 'gammastep (night light)' 'wlogout (secondary session menu)' 'grimblast-git (screenshot freeze)' 'hyprpicker-git (colour picker)' 'foot (terminal emulator)' 'firefox (web browser)' 'vscodium-bin (IDE)' 'thunar (file manager)' 'nemo (secondary file manager)' 'fuzzel (secondary app launcher)'

set -l hypr $CONFIG/../hypr

# Cause hyprland autogenerates a config file when it is removed
confirm-overwrite $hypr dummy
git clone 'https://github.com/caelestia-dots/hypr.git' /tmp/caelestia-hypr
rm -rf $hypr && mv /tmp/caelestia-hypr $hypr
hyprctl reload

pacman -Q ydotool &> /dev/null || sudo pacman -S --needed --noconfirm ydotool
systemctl --user enable --now ydotool.service

log 'Done.'
