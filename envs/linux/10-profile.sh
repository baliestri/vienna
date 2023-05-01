# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

## Check if variables have already been set
typeset -gU cdpath fpath mailpath path

## Set variables
path+=(
  ${HOME}/.asdf/shims
  ${HOME}/.dotnet/tools
  ${HOME}/.cargo/bin
  ${HOME}/.config/composer/vendor/bin
  ${HOME}/.local/share/pnpm
  ${HOME}/.local/bin
  ${HOME}/.local/sbin
  ${HOME}/.local/share/JetBrains/Toolbox/scripts
)

fpath+=(
  /usr/local/share/zsh-completions
  /usr/share/zsh/site-functions
  /usr/share/zsh/vendor-completions
  ${HOME}/.zi/bin/lib
)

## Check if profile has already been read
test -z "${PROFILEREAD}" &&
  source "/etc/profile" ||
  true
