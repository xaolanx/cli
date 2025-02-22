#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git hyprland-git hyprpaper-git okolors-git imagemagick wl-clipboard fuzzel-git socat foot jq python
install-optional-deps 'equibop-bin (discord client)' 'btop (system monitor)' 'wf-recorder (screen recorder)' 'grim (screenshot tool)' 'firefox (web browser)' 'spotify-adblock (music player)'

set -l dist $C_DATA/scripts

# Update/Clone repo
update-repo scripts $dist

# Install to path
mkdir -p ~/.local/bin
ln -sf $dist/main.fish ~/.local/bin/caelestia

# Install completions
mkdir -p $CONFIG/fish/completions
cp $dist/completions/caelestia.fish $CONFIG/fish/completions/caelestia.fish

log 'Done.'
