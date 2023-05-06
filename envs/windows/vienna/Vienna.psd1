# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

@{
  RootModule        = 'Vienna.psm1'
  ModuleVersion     = '0.1.0'
  GUID              = 'fcbe8b45-056b-4a0f-82b6-8ac314e8ee49'

  Author            = 'Bruno Sales'
  Copyright         = '(c) Bruno Sales. All rights reserved.'
  Description       = 'A PowerShell module to manage the terminal.'
  PowerShellVersion = '7.0'

  FunctionsToExport = '*'
  AliasesToExport   = '*'
  ScriptsToProcess  = @('ViennaTypes.ps1')
}
