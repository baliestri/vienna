# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

## Common environment variables
export EDITOR="nvim"
export PAGER="less"

export LESS="-g -i -M -R -S -w -X -z-4"

export CLICOLOR=1
export BLOCK_SIZE=human-readable
export HISTSIZE=11000
export SAVEHIST=10000
export HISTFILE="$HOME/.zhistory"

## GnuPG environment variables
unset SSH_AGENT_PID

[[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]] &&
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

export GPG_TTY=$(tty)

## Windows Subsystem for Linux environment variables
if cat "/proc/version" | grep -q "microsoft"; then
  export DISPLAY="${DISPLAY:-"$(ip route get 1.2.3.4 | awk '{print $3}'):0.0"}"
  export DONT_PROMPT_WSL_INSTALL=1

  [ -z "$XDG_RUNTIME_DIR" ] &&
    export XDG_RUNTIME_DIR="/run/user/$(id -ru)"

  [ -z "$DBUS_SESSION_BUS_ADDRESS" ] &&
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

## Plugins environment variables
export ZSH_PLUGINS_ALIAS_TIPS_TEXT="$(tput setaf 1)You should use:$(tput sgr0) "
export ZSH_AUTOSUGGEST_STRATEGY=(history)

export TAB_LIST_FILES_PREFIX=1
