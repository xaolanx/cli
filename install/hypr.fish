#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git uwsm hyprland-git hyprpaper-git hyprlock-git hypridle-git polkit-gnome gnome-keyring wl-clipboard wireplumber
install-optional-deps 'gammastep (night light)' 'wlogout (secondary session menu)' 'grimblast-git (screenshot freeze)' 'hyprpicker-git (colour picker)' 'foot (terminal emulator)' 'firefox (web browser)' 'vscodium-bin (IDE)' 'thunar (file manager)' 'nemo (secondary file manager)' 'fuzzel (secondary app launcher)' 'ydotool (alternate paste)'

set -l hypr $CONFIG/../hypr
set -l uwsm $CONFIG/../uwsm

# Cause hyprland autogenerates a config file when it is removed
confirm-overwrite $hypr dummy
git clone 'https://github.com/caelestia-dots/hypr.git' /tmp/caelestia-hypr
rm -rf $hypr && mv /tmp/caelestia-hypr $hypr

# Install uwsm envs
confirm-overwrite $uwsm
mv $hypr/uwsm $uwsm

# Enable ydotool if installed
pacman -Q ydotool &> /dev/null && systemctl --user enable --now ydotool.service

# Reload hyprland config to get rid of error messages
sleep .1
hyprctl reload

log 'Done.'
