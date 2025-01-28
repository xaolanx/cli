. (dirname (status filename))/../util.fish

function confirm-overwrite -a path
    if test -e $path
        read -l -p "input '$(realpath $path) already exists. Overwrite? [y/N] ' -n" confirm
        if test "$confirm" = 'y' -o "$confirm" = 'Y'
            log 'Continuing.'
            rm -rf $path
        else
            log 'Exiting.'
            exit
        end
    end
end

function install-deps
    # All dependencies already installed
    pacman -Q $argv &> /dev/null && return

    # Get AUR helper or install if none
    which yay > /dev/null && set -l helper yay || set -l helper paru
    if ! which paru > /dev/null
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

    # Install
    log "Installing dependencies '$argv'"
    $helper -S --needed --noconfirm $argv
end

function install-optional-deps
    for dep in $argv
        if ! pacman -Q $dep &> /dev/null
            read -l -p "input 'Install $dep? [Y/n] ' -n" confirm
            test "$confirm" != 'n' -a "$confirm" != 'N' && install-deps (cut -f 1 -d ' ' $dep)
        end
    end
end
