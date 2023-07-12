$ErrorActionPreference = 'Stop'

$ProfileSymLink = Get-ChildItem $PSScriptRoot -Filter "*profile.ps1" | Select-Object -ExpandProperty Target | Split-Path

if ($null -eq $ProfileSymLink) {
  $ProfileSymLink = Get-ChildItem $PSScriptRoot -Filter "init.ps1" | Split-Path -Parent
}

Import-Module "$ProfileSymLink/vienna/Vienna.psd1"
Import-Module "$ProfileSymLink/aliases/Vienna.Aliases.psd1" -DisableNameChecking
#Import-Module "$ProfileSymLink/hooks/Vienna.Hooks.psd1"

Register-Module "PSReadLine"
Register-Module "Terminal-Icons"
Register-Module "CompletionPredictor"
Register-Module "PSGitCompletions"

Use-Directory "."
