#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git adw-gtk-theme
install-optional-deps 'papirus-icon-theme (icon theme)'

set -l dist $C_DATA/gtk

# Update/Clone repo
update-repo gtk $dist

# Install systemd service
setup-systemd-monitor gtk $dist

# Set theme
gsettings set org.gnome.desktop.interface gtk-theme \'adw-gtk3-dark\'
if pacman -Q papirus-icon-theme &> /dev/null
    read -l -p "input 'Set icon theme to Papirus-Dark? [Y/n] ' -n" confirm
    test "$confirm" = 'n' -o "$confirm" = 'N' || gsettings set org.gnome.desktop.interface icon-theme \'Papirus-Dark\'
end

log 'Done.'
