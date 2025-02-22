#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git adw-gtk-theme

set -l dist $C_DATA/gtk

# Update/Clone repo
update-repo gtk $dist

# Install systemd service
setup-systemd-monitor gtk $dist

log 'Done.'
