#!/bin/fish

if test -z "$argv[1]"
    echo 'Usage: caelestia install discord <client_config_folder_name>'
    exit 1
end

. (dirname (status filename))/util.fish

install-deps git
install-optional-deps 'arrpc (rich presence)'

set -l client $CONFIG/$argv[1]
set -l dist $C_DATA/discord

# Update/Clone repo
update-repo discord $dist

# Install systemd service
setup-systemd-monitor discord $dist

# Link themes to client config
install-link $dist/themes $client/themes

log 'Done.'
