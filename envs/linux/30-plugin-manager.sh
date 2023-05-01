# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

# Check if the plugin manager is installed
if [[ ! -f "${HOME}/.zi/bin/zi.zsh" ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "${HOME}/.zi" && command chmod g-rwX "${HOME}/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "${HOME}/.zi/bin" &&
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" ||
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "${HOME}/.zi/bin/zi.zsh"
