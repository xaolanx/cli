#!/bin/fish

. (dirname (status filename))/util.fish

install-deps git adw-gtk-theme

set -l gtk $CONFIG/gtk
set -l systemd $CONFIG/../systemd/user

confirm-overwrite $gtk
git clone 'https://github.com/caelestia-dots/gtk.git' $gtk

# Install systemd service
if test -d $systemd
    log 'Installing systemd service...'

    echo "[Service]
Type=oneshot
ExecStart=$gtk/monitor/update.fish" > $systemd/gtk-monitor-scheme.service
    cp $gtk/monitor/gtk-monitor-scheme.path $systemd/gtk-monitor-scheme.path

    systemctl --user daemon-reload
    systemctl --user enable --now gtk-monitor-scheme.path
    systemctl --user start gtk-monitor-scheme.service
end

log 'Done.'
