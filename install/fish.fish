#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git starship fastfetch

set -l dist $C_DATA/fish

# Update/Clone repo
update-repo fish $dist

# Install fish config
confirm-overwrite $CONFIG/fish/config.fish
ln -s $dist/config.fish $CONFIG/fish/config.fish

# Install fish greeting
confirm-overwrite $CONFIG/fish/functions/fish_greeting.fish
mkdir -p $CONFIG/fish/functions
ln -s $dist/fish_greeting.fish $CONFIG/fish/functions/fish_greeting.fish

# Install starship config
confirm-overwrite $CONFIG/starship.toml
ln -s $dist/starship.toml $CONFIG/starship.toml

# Install fastfetch config
confirm-overwrite $CONFIG/fastfetch/config.jsonc
ln -s $dist/fastfetch.jsonc $CONFIG/fastfetch/config.jsonc

log 'Done.'
