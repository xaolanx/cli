#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git adw-gtk-theme
install-optional-deps 'xsettingsd (for live reload)' 'glib2 (for live reload)'

set -l gtk $CONFIG/gtk

confirm-overwrite $gtk
git clone 'https://github.com/caelestia-dots/gtk.git' $gtk

log 'Done.'
