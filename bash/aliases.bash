# This file include my aliases and is sourced in ~/.bashrc

# Short name for commands
alias .='pwd'

alias all='egrep alias ~/.bash_aliases'

# git shortcuts
alias ga='git add . && git status -b -s'
alias gb='git branch'
alias gc='git commit'
alias gcl='git clean -dfx'
alias gdt='git difftool -y'
alias gs='git status -b -s'
alias g='gvim'
alias v='vim'

# vim shortcuts
alias vpi='vim -c PlugInstall -c qa'
alias vpcl='vim -c PlugClean! -c qa'

# Commands redefined
alias cp='cp -rf'
alias gdb='gdb -q'
alias ls='ls -F --color'
alias ll='ls -lF --color'
alias rm='rm -rf'
