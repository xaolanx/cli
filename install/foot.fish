#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git foot inotify-tools

set -l foot $CONFIG/../foot

confirm-overwrite $foot
git clone 'https://github.com/caelestia-dots/foot.git' $foot
sed -i 's|$SRC|'$foot'|g' $foot/foot.ini

log 'Done.'
