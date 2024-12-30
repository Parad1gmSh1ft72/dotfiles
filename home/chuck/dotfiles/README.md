
      ██            ██     ████ ██  ██
     ░██           ░██    ░██░ ░░  ░██
     ░██  ██████  ██████ ██████ ██ ░██  █████   ██████
  ██████ ██░░░░██░░░██░ ░░░██░ ░██ ░██ ██░░░██ ██░░░░
 ██░░░██░██   ░██  ░██    ░██  ░██ ░██░███████░░█████
░██  ░██░██   ░██  ░██    ░██  ░██ ░██░██░░░░  ░░░░░██
░░██████░░██████   ░░██   ░██  ░██ ███░░██████ ██████
 ░░░░░░  ░░░░░░     ░░    ░░   ░░ ░░░  ░░░░░░ ░░░░░░

  ▓▓▓▓▓▓▓▓▓▓
 ░▓ about  ▓ custom linux config files
 ░▓ author ▓ Parad1gmSh1ft <charlescravens@gmail.com>
 ░▓ code   ▓ https://github.com/Parad1gmSh1ft72/dotfiles
 ░▓ mirror ▓ https://parad1gmsh1ft72.github.io
 ░▓▓▓▓▓▓▓▓▓▓
 ░░░░░░░░░░
 
alias dotfiles='git --git-dir=/home/chuck/dotfiles --work-tree=/'

Now typing dotfiles status or dotfiles log will show the status or log of the repo, regardless of if you're currently in another repo. Of course looking at the status will probably take forever as the work tree is /, so it will list every single file on the filesystem as untracked. There are a few ways to stop this, but I went with simply telling git not to show untracked files:

      dotfiles config --local status.showUntrackedFiles no

Example:
      dotfiles add ~/.bashrc
      dotfiles add /etc/udev/rules.d/70-ftdi.rules
      dotfiles commit

      alias dtig='GIT_DIR=/home/mx/.dotfiles GIT_WORK_TREE=/ tig'
 
Second, because of the huge spread of where files are, I found myself always needing to list which files are explicitly tracked, using dotfiles ls-files. It's really helpful to be able to quickly see where that config file was that you need to edit again. I went a bit overboard here and added a bash function to display a summary.

dot(){
  if [[ "$#" -eq 0 ]]; then
    (cd /
    for i in $(dotfiles ls-files); do
      echo -n "$(dotfiles -c color.status=always status $i -s | sed "s#$i##")"
      echo -e "¬/$i¬\e[0;33m$(dotfiles -c color.ui=always log -1 --format="%s" -- $i)\e[0m"
    done
    ) | column -t --separator=¬ -T2
  else
    dotfiles $*
  fi
}

If called with arguments, it just invokes dotfiles, so I can do dot status or whatever. Otherwise, it shows me a fancy summary that looks like this:
