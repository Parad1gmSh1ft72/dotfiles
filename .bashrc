#    _               _
#   | |__   __ _ ___| |__  _ __ ___
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__
# (_)_.__/ \__,_|___/_| |_|_|  \___|
#
# by Charles Cravens (2024)
# -----------------------------------------------------
# ~/.bashrc
# -----------------------------------------------------

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '

# -----------------------------------------------------
# LOAD CUSTOM .bashrc_custom
# -----------------------------------------------------
if [ -f ~/.bashrc_custom ] ;then
    source ~/.bashrc_custom
fi

export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/share/gem/ruby/3.0.0/bin:/usr/local/bin:$PATH

# Nice username colors
export PS1='\[\e[0;36m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;35m\]\w\[\e[0m\]> '

# test -r ~/.dir_colors && eval $(dircolors ~/.dir_colors)

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# ----------------------------------------------------
#CUSTOM COMMANDS:
# ----------------------------------------------------

# Define Editor
export EDITOR=nano

# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------
alias c='clear'
alias ff='fastfetch'
alias lc='colorls -lA --sd'
alias ls='colorls -al --color=always --group-directories-first' # my preferred listing
alias la='colorls -a --color=always --group-directories-first'  # all files and dirs
alias ll='colorls -l --color=always --group-directories-first'  # long format
alias lt='colorls -t --color=always --group-directories-first'  # tree listing
alias l.='colorls -al --color=always --group-directories-first ../' # ls on the PARENT directory
alias l..='colorls -al --color=always --group-directories-first ../../' # ls on directory 2 levels up
alias l...='colorls -al --color=always --group-directories-first ../../../' # ls on directory 3 levels up
alias shutdown='systemctl poweroff'
alias n='$EDITOR'
alias nano='$EDITOR'
alias ts='~/dotfiles/scripts/snapshot.sh'
alias wifi='nmtui'
alias dot="cd ~/dotfiles"
alias cleanup='~/dotfiles/scripts/cleanup.sh'

# -----------------------------------------------------
# ML4W Apps
# -----------------------------------------------------
alias ml4w='~/dotfiles/apps/ML4W_Welcome-x86_64.AppImage'
alias ml4w-settings='~/dotfiles/apps/ML4W_Dotfiles_Settings-x86_64.AppImage'
alias ml4w-sidebar='~/dotfiles/eww/ml4w-sidebar/launch.sh'
alias ml4w-hyprland='~/dotfiles/apps/ML4W_Hyprland_Settings-x86_64.AppImage'
alias ml4w-diagnosis='~/dotfiles/hypr/scripts/diagnosis.sh'
alias ml4w-hyprland-diagnosis='~/dotfiles/hypr/scripts/diagnosis.sh'
alias ml4w-qtile-diagnosis='~/dotfiles/qtile/scripts/diagnosis.sh'
alias ml4w-update='~/dotfiles/update.sh'

# -----------------------------------------------------
# Window Managers
# -----------------------------------------------------

alias Qtile='startx'
# Hyprland with Hyprland

# -----------------------------------------------------
# GIT
# -----------------------------------------------------
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gcheck="git checkout"
alias gcredential="git config credential.helper store"

# -----------------------------------------------------
# SCRIPTS
# -----------------------------------------------------
alias ascii='~/dotfiles/scripts/figlet.sh'

# -----------------------------------------------------
# SYSTEM
# -----------------------------------------------------
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# -----------------------------------------------------
# QTILE
# -----------------------------------------------------
alias res1='xrandr --output DisplayPort-0 --mode 2560x1440 --rate 120'
alias res2='xrandr --output DisplayPort-0 --mode 1920x1080 --rate 120'
alias setkb='setxkbmap de;echo "Keyboard set back to de."'

export PATH="/usr/lib/ccache/bin/:$PATH"

# -----------------------------------------------------
# PYWAL
# -----------------------------------------------------
cat ~/.cache/wal/sequences

# -----------------------------------------------------
# Fastfetch if on wm
# -----------------------------------------------------
if [[ $(tty) == *"pts"* ]]; then
    fastfetch --config examples/13
else
    echo
    if [ -f /bin/qtile ]; then
        echo "Start Qtile X11 with command Qtile"
    fi
    if [ -f /bin/hyprctl ]; then
        echo "Start Hyprland with command Hyprland"
    fi
fi
