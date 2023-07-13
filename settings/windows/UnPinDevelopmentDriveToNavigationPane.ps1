# Pin Development Drive to Navigation Pane
# Created by: Bruno Sales
# Created on: July 12, 2023
# Last modified by: Bruno Sales

$ErrorActionPreference = "Continue"

$Confirmation = Read-Host "Do you want to remove the Development Drive from the Navigation Pane? (Y/N)"

if ($Confirmation -ne "Y") {
  return
}

$GUID = "{9295F855-1DB0-45D8-85FC-3D3F8246FBAF}"

Remove-Item -Path "HKCU:\Software\Classes\CLSID\$GUID" -Recurse
Remove-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID" -Recurse
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$GUID" -Recurse
Remove-Item -Path "HKCU:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$GUID"
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "$GUID"
