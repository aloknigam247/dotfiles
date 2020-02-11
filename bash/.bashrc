# Modified to show git branch also
export PS1=${PS1%.}'\[\033[01;31m\]$(__git_ps1)\[\033[00m\]\$ '

# Display line number when debugging bash script
export PS4='Line ${LINENO}: '

# ENV Configs
export EDITOR='gvim'
export CSCOPE_EDITOR='gvim'
export GIT_EDITOR='gvim -f'

# Source your alias
source ~/.aliases.bash
