# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

@{
  RootModule        = 'Hooks.psm1'
  ModuleVersion     = '0.1.0'
  GUID              = 'cd48a519-34e7-45b4-a9b8-809b140f50a8'

  Author            = 'Bruno Sales'
  Copyright         = '(c) Bruno Sales. All rights reserved.'
  Description       = 'A PowerShell module to manage hooks.'
  PowerShellVersion = '7.0'

  RequiredModules   = @('PSReadLine')

  FunctionsToExport = '*-*'
  AliasesToExport   = '*'
}
