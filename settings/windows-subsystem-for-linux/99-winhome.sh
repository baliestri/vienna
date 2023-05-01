#!/usr/bin/env bash

# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

export WINHOME="${HOME}/winhome"

if [[ -d "/mnt/c/Users/${USER}" ]]; then
  ln -sf "/mnt/c/Users/${USER}" "${WINHOME}"
else
  if command -v powershell.exe >/dev/null 2>&1; then
    declare WINUSERNAME="$(powershell.exe -Command 'echo $env:USERNAME')"

    if [[ -d "/mnt/c/Users/${WINUSERNAME}" ]]; then
      ln -sf "/mnt/c/Users/${WINUSERNAME}" "${WINHOME}"
    fi
  elif command -v cmd.exe >/dev/null 2>&1; then
    declare WINUSERNAME="$(cmd.exe /c 'echo %USERNAME%')"

    if [[ -d "/mnt/c/Users/${WINUSERNAME}" ]]; then
      ln -sf "/mnt/c/Users/${WINUSERNAME}" "${WINHOME}"
    fi
  else
    unset WINHOME
  fi
fi

unset WINUSERNAME
