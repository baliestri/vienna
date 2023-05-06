# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

<#
.SYNOPSIS
Uses scripts stored in a directory.

.DESCRIPTION
Uses scripts stored in a directory recursively.

.PARAMETER Directory
The directory where scripts are stored.

.PARAMETER BaseDirectory
The base directory to the specified directory.

.PARAMETER Exclude
Files or folders to be excluded from the script. (Supports Wildcards)

.EXAMPLE
Use-Directory "aliases"

.EXAMPLE
Use-Directory "aliases" -Exclude "*.exclude.ps1"

.EXAMPLE
Use-Directory "env" "./scripts"
#>
function Use-Directory {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Directory,

    [Parameter(Position = 1)]
    [string]$BaseDirectory = $Global:ProfileSymLink,

    [Parameter(Position = 2)]
    [SupportsWildcards()]
    [string[]]$Exclude
  )

  begin {
    $Path = Join-Path $BaseDirectory $Directory
    $Exclude += @("init.ps1")
  }

  process {
    if (-not (Test-Path $Path)) {
      Write-Error "The given directory '$Directory' does not exists on '$BaseDirectory'" -Category InvalidOperation
      return
    }
  }

  end {
    Push-Location $Path
    Get-ChildItem "*.ps1" -File -Recurse -Exclude $Exclude | ForEach-Object {
      . $_
    }
    Pop-Location
  }
}

<#
.SYNOPSIS
Returns one or all registered modules.

.DESCRIPTION
Returns one or all registered modules.

.PARAMETER Name
The module name.

.EXAMPLE
Get-RegisteredModule "PSReadLine"

.EXAMPLE
PS C:\> Get-RegisteredModule -All
#>
function Get-RegisteredModule {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "AsModule", ValueFromPipeline = $true, HelpMessage = "The name of the module registered.")]
    [ValidateNotNullOrEmpty()][string]$Name,

    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "AsModules", ValueFromPipeline = $true, HelpMessage = "List all registered modules.")]
    [switch]$All
  )

  end {
    switch ($PSCmdlet.ParameterSetName) {
      "AsModule" {
        $ModuleInfo = [PSCoreModule]::RegisteredModules | Where-Object { $_.Name -eq $Name }

        if ($null -eq $ModuleInfo) {
          throw [InvalidOperationException]::new("The module '$Name' is not registered.")
        }

        return $ModuleInfo
      }
      "AsModules" {
        return [PSCoreModule]::RegisteredModules
      }
    }
  }
}

<#
.SYNOPSIS
Register a module.

.DESCRIPTION
Register a module.

.EXAMPLE
PS C:\> Register-Module -Name "PSReadLine" -MinimumVersion "2.1.0" -SupportedPlatforms @([PSCoreSupportedPlatform]::Windows)
PS C:\> Register-Module -Name "Terminal-Icons" -MinimumVersion "1.0.0" -SupportedPlatforms @([PSCoreSupportedPlatform]::Windows, [PSCoreSupportedPlatform]::Linux, [PSCoreSupportedPlatform]::OSX)
#>
function Register-Module {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "The name of the module to be installed.")]
    [ValidateNotNullOrEmpty()][string]$Name,

    [Parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = "The minimum version of the module to be installed.")]
    [ValidateNotNullOrEmpty()][string]$MinimumVersion = "0.0.0",

    [Parameter(Mandatory = $false, Position = 2, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()][PSCoreSupportedPlatform[]]$SupportedPlatforms = @(
      [PSCoreSupportedPlatform]::Linux,
      [PSCoreSupportedPlatform]::OSX,
      [PSCoreSupportedPlatform]::Windows
    )
  )

  begin {
    if ($null -ne (Get-RegisteredModule -Name $Name -ErrorAction SilentlyContinue)) {
      return
    }

    if (($Platform -contains [PSCoreSupportedPlatform]::Windows -and $IsWindows -eq $false) -or `
      ($Platform -contains [PSCoreSupportedPlatform]::Linux -and $IsLinux -eq $false) -or `
      ($Platform -contains [PSCoreSupportedPlatform]::OSX -and $IsOSX -eq $false)) {
      [PSCoreModule]::Add([PSCoreModule]::Create($Name, $MinimumVersion, $SupportedPlatforms))
      return
    }
  }

  process {
    try {
      Import-Module -Name $Name -DisableNameChecking -Scope Local -Force
    }
    catch {
      Install-Module $_.TargetObject -AllowPrerelease -AllowClobber -AcceptLicense -Scope CurrentUser
      Import-Module $_.TargetObject -DisableNameChecking -Scope Local -Force
    }
  }

  end {
    $MinimumVersion = Get-Module -Name $Name | Select-Object -ExpandProperty Version -First 1

    [PSCoreModule]::Add([PSCoreModule]::Create($Name, $MinimumVersion, $SupportedPlatforms))
  }
}

<#
.SYNOPSIS
Restart the current PowerShell session.

.DESCRIPTION
Restart the current PowerShell session.

.EXAMPLE
PS C:\> Restart-PowerShell
#>
function Restart-PowerShell {
  [Alias("reload")]
  param()

  begin {
    Write-Information "Restarting PowerShell..." -InformationAction Continue
  }

  process {
    Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } }
  }

  end {
    exit
  }
}

function ~ { Set-Location $env:HOME }
function .. { Set-Location ".." }
function ... { Set-Location "..\.." }
function .... { Set-Location "..\..\.." }
function ..... { Set-Location "..\..\..\.." }
function ...... { Set-Location "..\..\..\..\.." }
function ....... { Set-Location "..\..\..\..\..\.." }
function ll { Get-ChildItem -Force -ErrorAction SilentlyContinue }
function la { Get-ChildItem -Force -ErrorAction SilentlyContinue -File }
function l { Get-ChildItem -Force -ErrorAction SilentlyContinue -File }
function vim { nvim $args }
function vi { nvim $args }
function touch { New-Item -ItemType File $args }
function which {
  $RequestedCommand = $args[0]
  $FoundResult = Get-Command $RequestedCommand -ErrorAction SilentlyContinue
  $Response = $null

  switch ($FoundResult.CommandType) {
    "Alias" {
      $Response = [PSCustomObject]@{
        CommandType = $FoundResult.CommandType
        Definition  = "$($FoundResult.Name) -> $($FoundResult.Definition)"
      }
    }
    "Application" {
      $Response = [PSCustomObject]@{
        CommandType = $FoundResult.CommandType
        Path        = $FoundResult.Path
      }
    }
    "Cmdlet" {
      $Response = [PSCustomObject]@{
        CommandType = $FoundResult.CommandType
        Name        = $FoundResult.Name
        Namespace   = $FoundResult.Source
      }
    }
    "Function" {
      $Response = [PSCustomObject]@{
        CommandType = $FoundResult.CommandType
        Name        = $FoundResult.Name
        Namespace   = $FoundResult.Source
      }
    }
    Default {
      $Response = "which: no $RequestedCommand in ($env:PATH)"
    }
  }

  return $Response
}
