#.........%%%%%%...%%%%...%%..%%..%%%%%....%%%%..
#............%%...%%......%%..%%..%%..%%..%%..%%.
#...........%%.....%%%%...%%%%%%..%%%%%...%%.....
#...%%.....%%.........%%..%%..%%..%%..%%..%%..%%.
#...%%....%%%%%%...%%%%...%%..%%..%%..%%...%%%%..
................................................
# -----------------------------------------------------
#  zshrc loader - Charles Cravens 2025
# -----------------------------------------------------

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/.config/zshrc
# or by creating a folder ~/.config/zshrc/custom
# with copies of files from ~/.config/zshrc
# -----------------------------------------------------

# -----------------------------------------------------
# Load modular configarion
# -----------------------------------------------------

for f in ~/.config/zshrc/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=.config/zshrc=.config/zshrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done

# -----------------------------------------------------
# Load single customization file (if exists)
# -----------------------------------------------------

if [ -f ~/.zshrc_custom ]; then
    source ~/.zshrc_custom
fi
