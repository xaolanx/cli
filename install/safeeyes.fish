#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git dart-sass aylurs-gtk-shell-git alsa-utils libappindicator-gtk3

set -l safeeyes $CONFIG/safeeyes

confirm-overwrite $safeeyes
git clone 'https://github.com/caelestia-dots/safeeyes.git' $safeeyes

log 'Done.'
