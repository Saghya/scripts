#
# ~/.bashrc
#

# If not running interactively, don't do anything

neofetch

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
# PS1='[\u@\h \W]\$ '
#PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
PS1="\[\e[32m\]\w\[\e[m\] \$ "

export PATH="$HOME/.scripts:$PATH"
