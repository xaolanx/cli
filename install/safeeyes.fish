#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git dart-sass aylurs-gtk-shell-git alsa-utils libappindicator-gtk3

# Update/Clone repo
update-repo safeeyes $C_DATA/safeeyes

log 'Done.'
