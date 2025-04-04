#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git dart-sass libastal-gjs-git libastal-meta npm curl libnotify ttf-material-symbols-variable-git ttf-jetbrains-mono-nerd ttf-rubik-vf pacman-contrib
install-optional-deps 'uwsm (for systems using uwsm)' 'yay (AUR package management)' 'fd (launcher file search)' 'tod-bin (launcher todo action)' 'wl-clipboard (clipboard support)' 'foot (opening stuff in terminal)'

set -l shell $C_DATA/shell

# Update/Clone repo
update-repo shell $shell

cd $shell || exit
npm install

if which systemctl &> /dev/null
    log 'Installing systemd service...'

    set -l systemd $CONFIG/systemd/user
    mkdir -p $systemd
    echo -n "
[Unit]
Description=A visually stunning and feature-rich desktop shell made for the Caelestia project.
After=graphical-session.target

[Service]
Type=exec
ExecStart=$shell/run.fish
Restart=on-failure
Slice=app-graphical.slice

[Install]
WantedBy=graphical-session.target
" > $systemd/caelestia-shell.service

    systemctl --user daemon-reload
    systemctl --user enable --now caelestia-shell.service
end

log 'Done.'
