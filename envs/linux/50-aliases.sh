# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

# Variables
shellrc=[[ -z "${ZSH_VERSION}" ]] && shellrc="${HOME}/.bashrc" || shellrc="${HOME}/.zshrc"

# Common
alias refresh="source ${shellrc}"
alias reload="exec ${SHELL} -l"

unset shellrc
