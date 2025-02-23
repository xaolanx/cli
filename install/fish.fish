#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git starship fastfetch

set -l dist $C_DATA/fish

# Update/Clone repo
update-repo fish $dist

# Install fish config
install-link $dist/config.fish $CONFIG/fish/config.fish

# Install fish greeting
mkdir -p $CONFIG/fish/functions
install-link $dist/fish_greeting.fish $CONFIG/fish/functions/fish_greeting.fish

# Install starship config
install-link $dist/starship.toml $CONFIG/starship.toml

# Install fastfetch config
install-link $dist/fastfetch.jsonc $CONFIG/fastfetch/config.jsonc

log 'Done.'
