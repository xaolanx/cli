#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git fuzzel-git

set -l systemd $CONFIG/../systemd/user
set -l fuzzel $CONFIG/../fuzzel

# Clone repo
confirm-overwrite $fuzzel
git clone 'https://github.com/caelestia-dots/fuzzel.git' $fuzzel

# Install systemd service
if test -d $systemd
    log 'Installing systemd service...'

    echo "[Service]
Type=oneshot
ExecStart=$fuzzel/monitor/update.fish" > $systemd/fuzzel-monitor-scheme.service
    cp $fuzzel/monitor/fuzzel-monitor-scheme.path $systemd/fuzzel-monitor-scheme.path

    systemctl --user daemon-reload
    systemctl --user enable --now fuzzel-monitor-scheme.path
    systemctl --user start fuzzel-monitor-scheme.service
end

log 'Done.'
