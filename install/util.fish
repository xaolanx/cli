. (dirname (status filename))/../util.fish

function confirm-overwrite -a path
    if test -e $path
        read -l -p "input '$(realpath $path) already exists. Overwrite? [y/N] ' -n" confirm
        if test "$confirm" = 'y' -o "$confirm" = 'Y'
            log 'Continuing.'
            test -z "$argv[2]" && rm -rf $path  # If a second arg is provided, don't delete
        else
            log 'Exiting.'
            exit
        end
    end
end

function install-deps
    # All dependencies already installed
    pacman -Q $argv &> /dev/null && return

    for dep in $argv
        # Skip if already installed
        if ! pacman -Q $dep &> /dev/null
            # If pacman can install it, use it, otherwise use an AUR helper
            if pacman -Si $dep &> /dev/null
                log "Installing dependency '$dep'"
                sudo pacman -S --noconfirm $dep
            else
                # Get AUR helper or install if none
                which yay &> /dev/null && set -l helper yay || set -l helper paru
                if ! which $helper &> /dev/null
                    warn 'No AUR helper found'
                    read -l -p "input 'Install yay? [Y/n] ' -n" confirm
                    if test "$confirm" = 'n' -o "$confirm" = 'N'
                        warn "Manually install yay or paru and try again."
                        warn "Alternatively, install the dependencies '$argv' manually and try again."
                        exit
                    else
                        sudo pacman -S --needed git base-devel
                        git clone https://aur.archlinux.org/yay.git
                        cd yay
                        makepkg -si
                        cd ..
                        rm -rf yay

                        # First use, see https://github.com/Jguer/yay?tab=readme-ov-file#first-use
                        yay -Y --gendb
                        yay -Y --devel --save
                    end
                end

                log "Installing dependency '$dep'"
                $helper -S --noconfirm $dep
            end
        end
    end
end

function install-optional-deps
    for dep in $argv
        set -l dep_name (string split -f 1 ' ' $dep)
        if ! pacman -Q $dep_name &> /dev/null
            read -l -p "input 'Install $dep? [Y/n] ' -n" confirm
            test "$confirm" != 'n' -a "$confirm" != 'N' && install-deps $dep_name
        end
    end
end

function update-repo -a module dir
    set -l remote https://github.com/caelestia-dots/$module.git
    if test -d $dir
        cd $dir || exit
        if test "$(git config --get remote.origin.url)" != $remote
            cd .. || exit
            confirm-overwrite $dir
            git clone $remote $dir
        else
            git pull
        end
    else
        git clone $remote $dir
    end
end

function setup-systemd-monitor -a module dir
    set -l systemd $CONFIG/systemd/user
    if which systemctl &> /dev/null
        log 'Installing systemd service...'

        mkdir -p $systemd
        echo "[Unit]
Description=Sync $module and caelestia schemes

[Service]
Type=oneshot
ExecStart=$dir/monitor/update.fish" > $systemd/$module-monitor-scheme.service
        echo "[Unit]
Description=Sync $module and caelestia schemes (monitor)

[Path]
PathModified=%S/caelestia/scheme/current.txt
Unit=$module-monitor-scheme.service

[Install]
WantedBy=default.target" > $systemd/$module-monitor-scheme.path

        systemctl --user daemon-reload
        systemctl --user enable --now $module-monitor-scheme.path
        systemctl --user start $module-monitor-scheme.service
    end
end

function install-link -a from to
    if ! test -L $to -a "$(realpath $to 2> /dev/null)" = $from
        mkdir -p (dirname $to)
        confirm-overwrite $to
        ln -s $from $to
    end
end
