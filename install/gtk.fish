#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git adw-gtk-theme

set -l gtk $CONFIG/gtk

confirm-overwrite $gtk
git clone 'https://github.com/caelestia-dots/gtk.git' $gtk

log 'Done.'
