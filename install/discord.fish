#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git
install-optional-deps 'arrpc (rich presence)'

set -l dist $C_DATA/discord

# Update/Clone repo
update-repo discord $dist

# Install systemd service
setup-systemd-monitor discord $dist

# Link themes to client configs
set -l clients discord vesktop equibop legcord $argv
for client in $clients
    if test -d $CONFIG/$client
        log "Linking themes for $client"
        install-link $dist/themes $CONFIG/$client/themes
    end
end

log 'Done.'
