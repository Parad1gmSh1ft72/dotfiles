#    _               _
#   | |__   __ _ ___| |__  _ __ ___
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__
# (_)_.__/ \__,_|___/_| |_|_|  \___|
#
# by Charles Cravens (2024)
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '

# Nice username colors
export PS1='\[\e[0;36m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;35m\]\w\[\e[0m\]>'

# Use bash-completion, if available
#[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
#    . /usr/share/bash-completion/bash_completion

export GPG_TTY=$TTY
export EDITOR=nano

# ----------------------------------------------------
# CUSTOM COMMANDS:
# ----------------------------------------------------

# SET MANPAGER
# Uncomment only one of these!

# "nvim" as manpager
export MANPAGER="nvim +Man!"

# "less" as manpager
#export MANPAGER="less"

# Changing "ls" to "eza"
alias ldot='eza -ld .*'                                                               # List dotfiles only (directories shown as entries instead of recursed into)
alias ll='eza -alh --icons --color=always --group-directories-first'                  # List files as a long list
alias lt='eza -alh --tree --icons --level=1 --color=always --group-directories-first' # tree listing
alias ls='eza -ah --icons --color=always --group-directories-first'                   # eza ls call
alias lD='eza -lD'                                                                    # List only directories (excluding dotdirs) as a long list
alias lDD='eza -laD'                                                                  # List only directories (including dotdirs) as a long list
alias lsd='eza -d'                                                                    # List specified files with directories as entries, in a grid
alias lsdl='eza -dl'                                                                  # List specified files with directories as entries, in a long list
alias lS='eza -al -ssize'                                                             # List files as a long list, sorted by size
alias lT='eza -l -snewest'                                                            # List files as a long list, sorted by date (newest last)
alias l.='eza -al --color=always --group-directories-first ../'                       # ls on the PARENT directory
alias l..='eza -al --color=always --group-directories-first ../../'                   # ls on directory 2 levels up
alias l...='eza -al --color=always --group-directories-first ../../../'               # ls on directory 3 levels up
alias grep='grep --color=auto'

# navigation
alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"

alias ff='fastfetch'

# pacman and yay
alias update='sudo pacman -Syu'                 # update only standard pkgs
alias pacsyu='sudo pacman -Syu'                 # update only standard pkgs
alias pacsyyu='sudo pacman -Syyu'               # Refresh pkglist & update standard pkgs
alias yaysua='yay -Sua --noconfirm'             # update only AUR pkgs (yay)
alias yaysyu='yay -Syu --noconfirm'             # update standard pkgs and AUR pkgs (yay)
alias unlock='sudo rm /var/lib/pacman/db.lck'   # remove pacman lock
alias orphan='sudo pacman -Rns $(pacman -Qtdq)' # remove orphaned packages (DANGEROUS!)
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
# 6. Better copying
alias cpv='rsync -avh --info=progress2'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
# verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# GIT
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gcheck="git checkout"
alias gcredential="git config credential.helper store"
#alias dotsync="~/dotfiles-versions/dotfiles/.dev/sync.sh dotfiles"

# bare git repo alias for managing my dotfiles
#alias config="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"
alias dotfiles='/usr/bin/git --git-dir="$HOME/dotfiles/" --work-tree=/'
alias dtig='GIT_DIR=/home/chuck/dotfiles GIT_WORK_TREE=/ tig'

# vim and emacs
alias vim="nvim"
#alias emacs="emacsclient -c -a 'emacs'" # GUI versions of Emacs
#alias em="/usr/bin/emacs -nw" # Terminal version of Emacs
#alias rem="killall emacs || echo 'Emacs server not running'; /usr/bin/emacs --daemon" # Kill Emacs and restart daemon..

# Sudo last command
s() { # do sudo, or sudo the last command if no argument given
    if [[ $# == 0 ]]; then
        sudo '$(history -p '!!')'
    else
        sudo "$@"
    fi
}

# 8. Find string in files
fstr() {
    grep -Rnw "." -e "$1"
}

# 10. Easy extract
function extract {
    if [ $# -eq 0 ]; then
        # display usage if no parameters given
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
        echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    fi
    for n in "$@"; do
        if [ ! -f "$n" ]; then
            echo "'$n' - file doesn't exist"
            return 1
        fi

        case "${n%,}" in
        *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
            tar zxvf "$n"
            ;;
        *.lzma) unlzma ./"$n" ;;
        *.bz2) bunzip2 ./"$n" ;;
        *.cbr | *.rar) unrar x -ad ./"$n" ;;
        *.gz) gunzip ./"$n" ;;
        *.cbz | *.epub | *.zip) unzip ./"$n" ;;
        *.z) uncompress ./"$n" ;;
        *.7z | *.apk | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar | *.vhd)
            7z x ./"$n"
            ;;
        *.xz) unxz ./"$n" ;;
        *.exe) cabextract ./"$n" ;;
        *.cpio) cpio -id <./"$n" ;;
        *.cba | *.ace) unace x ./"$n" ;;
        *.zpaq) zpaq x ./"$n" ;;
        *.arc) arc e ./"$n" ;;
        *.cso) ciso 0 ./"$n" ./"$n.iso" &&
            extract "$n.iso" && \rm -f "$n" ;;
        *.zlib) zlib-flate -uncompress <./"$n" >./"$n.tmp" &&
            mv ./"$n.tmp" ./"${n%.*zlib}" && rm -f "$n" ;;
        *.dmg)
            hdiutil mount ./"$n" -mountpoint "./$n.mounted"
            ;;
        *.tar.zst) tar -I zstd -xvf ./"$n" ;;
        *.zst) zstd -d ./"$n" ;;
        *)
            echo "extract: '$n' - unknown archive method"
            return 1
            ;;
        esac
    done
}

#dotfiles status
dot() {
    if [[ "$#" -eq 0 ]]; then
        (
            cd /
            for i in $(dotfiles ls-files); do
                echo -n "$(dotfiles -c color.status=always status $i -s | sed "s#$i##")"
                echo -e "¬/$i¬\e[0;33m$(dotfiles -c color.ui=always log -1 --format="%s" -- $i)\e[0m"
            done
        ) | column -t --separator=¬ -T2
    else
        dotfiles $*
    fi
}
