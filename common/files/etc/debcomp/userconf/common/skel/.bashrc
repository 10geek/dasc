[ -e /etc/bashrc ] && . /etc/bashrc
. /usr/local/lib/bash/xbash.bash || return

xbash_shell_preset

export \
	EDITOR=nano \
	SYSTEMD_PAGER=

unset -v HISTFILE
HISTCONTROL=erasedups:ignorespace
HISTSIZE=1000
