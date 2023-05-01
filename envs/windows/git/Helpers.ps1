<#
.SYNOPSIS
	Get current git branch.
#>
function Get-Git-CurrentBranch {
  end {
    git symbolic-ref --quiet HEAD *> $null

    if ($LASTEXITCODE -eq 0) {
      return git rev-parse --abbrev-ref HEAD
    }

    return
  }
}

function Get-Git-MainBranch {
  end {
    git rev-parse --git-dir *> $null

    if ($LASTEXITCODE -ne 0) {
      return
    }

    $Branches = @('main', 'trunk')

    foreach ($Branch in $Branches) {
      & git show-ref -q --verify refs/heads/$Branch

      if ($LASTEXITCODE -eq 0) {
        return $Branch
      }
    }

    return 'master'
  }
}

function Format-AliasDefinition {
  param (
    [Parameter(Mandatory = $true)][string]$Definition
  )

  process {
    $DefinitionLines = $Definition.Trim() -split "`n" | ForEach-Object {
      $Line = $_.TrimEnd()

      # Trim 1 indent
      if ($_ -match "^`t") {
        return $Line.Substring(1)
      }
      elseif ($_ -match '^    ') {
        return $Line.Substring(4)
      }

      return $Line
    }
  }

  end {
    return $DefinitionLines -join "`n"
  }
}

<#
.SYNOPSIS
	Get git aliases' definition.
.DESCRIPTION
	Get definition of all git aliases or specific alias.
.EXAMPLE
	PS C:\> Get-Git-Aliases
	Get definition of all git aliases.
.EXAMPLE
	PS C:\> Get-Git-Aliases -Alias gst
	Get definition of `gst` alias.
#>
function Get-Git-Aliases([string]$Alias) {
  $esc = [char] 27
  $green = 32
  $magenta = 35

  $Alias = $Alias.Trim()
  $blacklist = @(
    'Get-Git-CurrentBranch',
    'Remove-Alias',
    'Format-AliasDefinition',
    'Get-Git-Aliases'
  )
  $aliases = Get-Command -Module git-aliases | Where-Object { $_ -notin $blacklist }

  if (-not ([string]::IsNullOrEmpty($Alias))) {
    $foundAliases = $aliases | Where-Object -Property Name -Value $Alias -EQ

    if ($foundAliases -is [array]) {
      return Format-AliasDefinition($foundAliases[0].Definition)
    }
    else {
      return Format-AliasDefinition($foundAliases.Definition)
    }
  }

  $aliases = $aliases | ForEach-Object {
    $name = $_.Name
    $definition = Format-AliasDefinition($_.Definition)
    $definition = "$definition`n" # Add 1 line break for some row space

    return [PSCustomObject]@{
      Name       = $name
      Definition = $definition
    }
  }

  $cols = @(
    @{
      Name       = 'Name'
      Expression = {
        # Print alias name in green
        "$esc[$($green)m$($_.Name)$esc[0m"
      }
    },
    @{
      Name       = 'Definition'
      Expression = {
        # Print alias definition in yellow
        "$esc[$($magenta)m$($_.Definition)$esc[0m"
      }
    }
  )

  return Format-Table -InputObject $aliases -AutoSize -Wrap -Property $cols
}
