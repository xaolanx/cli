#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git hyprland-git hyprpaper-git okolors-git imagemagick wl-clipboard fuzzel-git socat foot jq
install-optional-deps 'vesktop-bin (discord client)' 'btop (system monitor)' 'wf-recorder (screen recorder)' 'grim (screenshot tool)' 'firefox (web browser)' 'spotify-adblock (music player)'

set -l dist $CONFIG/scripts

# Clone repo
confirm-overwrite $dist
git clone 'https://github.com/caelestia-dots/scripts.git' $dist

# Install to path
mkdir -p ~/.local/bin
ln -s $dist/main.fish ~/.local/bin/caelestia

# Install completions
mkdir -p $CONFIG/../fish/completions
cp $dist/completions/caelestia.fish $CONFIG/../fish/completions/caelestia.fish

log 'Done.'
