#!/bin/fish

if test -z "$argv[1]"
    echo 'Usage: caelestia install discord <client_config_folder_name>'
    exit 1
end

. (dirname (status filename))/util.fish

install-deps git
install-optional-deps 'arrpc (rich presence)'

set -l systemd $CONFIG/../systemd/user
set -l client $CONFIG/../$argv[1]
set -l discord $CONFIG/discord

# Clone repo
confirm-overwrite $discord
git clone https://github.com/caelestia-dots/discord.git $discord

# Install systemd service
if test -d $systemd
    log 'Installing systemd service...'

    echo "[Service]
Type=oneshot
ExecStart=$discord/monitor/update.fish" > $systemd/$discord-monitor-scheme.service
    cp $discord/monitor/discord-monitor-scheme.path $systemd/$discord-monitor-scheme.path

    systemctl --user daemon-reload
    systemctl --user enable --now $discord-monitor-scheme.path
    systemctl --user start $discord-monitor-scheme.service
end

# Link themes to client config
confirm-overwrite $client/themes
ln -s $discord/themes $client/themes

log 'Done.'
