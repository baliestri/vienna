# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

export PROFILE_PATH="$(dirname $(realpath "${HOME}/.zshrc"))"

pushd "${PROFILE_PATH}" > /dev/null
  declare -a files=($(find . -maxdepth 1 -type f -name "*.sh" ! -name "init.*" -printf "%f\n"))

  for file in $files; do
    source "${file}"
  done
popd > /dev/null

autoload -U +X compinit &&
  compinit
autoload -U +X bashcompinit &&
  bashcompinit
autoload -U +X zicompinit &&
  zicompinit
