# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# See /usr/share/doc/bash/examples/startup-files for examples.
# These files are located in the bash-doc package.

# Default umask
umask 022

# If running bash and ~/.bashrc exists
[ -n "$BASH_VERSION" ] && [ -f ~/.bashrc ] && . ~/.bashrc

# Set PATH so it includes user's private bin if it exists
case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) [ -d "$HOME/.local/bin" ] && PATH=$HOME/.local/bin:$PATH
esac
