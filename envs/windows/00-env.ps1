# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

$env:SSH_AUTH_SOCK = $(gpgconf --list-dirs agent-ssh-socket)
$env:EDITOR = "nvim"
$env:PAGER = "less"
