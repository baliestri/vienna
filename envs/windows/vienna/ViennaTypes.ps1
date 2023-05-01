# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

using namespace System.Collections.Generic

enum PSCoreSupportedPlatform {
  Linux
  OSX
  Windows
}

class PSCoreModule {
  [ValidateNotNullOrEmpty()][string]$Name
  [ValidateNotNullOrEmpty()][PSCoreSupportedPlatform[]]$SupportedPlatforms
  [ValidateNotNullOrEmpty()][string]$Version

  hidden static [List[PSCoreModule]]$RegisteredModules

  static PSCoreModule() {
    [PSCoreModule]::RegisteredModules = New-Object -TypeName List[PSCoreModule]

    $AvailableModules = Get-Module |`
      Select-Object -Property "Name", "Version" -Unique |`
      Sort-Object -Property "Name" |`
      Where-Object { $_.Name -ne "ViennaTypes" }

    $AvailableModules | ForEach-Object {
      $Module = $_

      $ModuleInfo = New-Object -TypeName PSCoreModule
      $ModuleInfo.Name = $Module.Name
      $ModuleInfo.Version = $Module.Version.ToString()
      $ModuleInfo.SupportedPlatforms = @(
        [PSCoreSupportedPlatform]::Linux,
        [PSCoreSupportedPlatform]::OSX,
        [PSCoreSupportedPlatform]::Windows
      )

      [PSCoreModule]::RegisteredModules.Add($ModuleInfo)
    }
  }

  static [PSCoreModule] Create([string]$name, [string]$version, [PSCoreSupportedPlatform[]]$supportedTypes) {
    if ($null -eq $name) {
      throw [ArgumentNullException]::new("name", "The module name cannot be null.")
    }

    if ($null -eq $supportedTypes) {
      throw [ArgumentNullException]::new("supportedTypes", "The module supported types cannot be null.")
    }

    if ($supportedTypes.Length -eq 0) {
      throw [ArgumentOutOfRangeException]::new("supportedTypes", "The module supported types cannot be empty.")
    }

    if ($null -eq $version) {
      throw [ArgumentNullException]::new("version", "The module version cannot be null.")
    }

    $ModuleInfo = New-Object -TypeName PSCoreModule
    $ModuleInfo.Name = $name
    $ModuleInfo.Version = $version
    $ModuleInfo.SupportedPlatforms = $supportedTypes

    return $ModuleInfo
  }

  static [void] Add([PSCoreModule]$module) {
    if ($null -eq $module) {
      throw [ArgumentNullException]::new("module", "The module cannot be null.")
    }

    [PSCoreModule]::RegisteredModules.Add($module)
  }

  static [void] Remove([PSCoreModule]$module) {
    if ($null -eq $module) {
      throw [ArgumentNullException]::new("module", "The module cannot be null.")
    }

    [PSCoreModule]::RegisteredModules.Remove($module)
  }
}
