#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git foot inotify-tools

set -l dist $CONFIG/foot

update-repo foot $dist
sed -i 's|$SRC|'$dist'|g' $dist/foot.ini

log 'Done.'
