# Load dependencies.
pmodload 'helper'

if is-darwin; then
    source $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br
else
    source $HOME/.config/broot/launcher/bash/br
fi
