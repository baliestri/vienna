# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

. $PSScriptRoot\Functions.ps1

<#
.SYNOPSIS
  Adds a hook to be executed when the current directory changes.

.DESCRIPTION
  Adds a hook to be executed when the current directory changes.

.PARAMETER ScriptBlock
  The script block to be executed when the current directory changes.

.EXAMPLE
  PS C:\> Add-ChangeCurrentDirectoryHook { Write-Host "Current directory changed to $PWD" }
#>
function Add-ChangeCurrentDirectoryHook {
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [scriptblock]$Hook
  )

  end {
    $Script:ChangeCurrentDirectoryHooks += $Hook
  }
}
