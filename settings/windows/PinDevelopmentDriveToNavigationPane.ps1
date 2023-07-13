# Pin Development Drive to Navigation Pane
# Created by: Bruno Sales
# Created on: July 12, 2023
# Last modified by: Bruno Sales

$ErrorActionPreference = "Continue"

$GUID = "{9295F855-1DB0-45D8-85FC-3D3F8246FBAF}"

$Name = Read-Host "Enter the name of the drive (e.g. Development Drive)"

if ($Name -eq "" -or $null -eq $Name) {
  $Name = "Development Drive"
}

$Icon = Read-Host "Enter the path to the icon file (e.g. $HOME\Development Drive.ico)"

if ($Icon -eq "" -or $null -eq $Icon) {
  $Icon = "$env:APPDATA\Vienna\icons\development-drive.ico"
}

$Target = Read-Host "Enter the path to the target folder (e.g. $HOME\Development Drive)"

if ($Target -eq "" -or $null -eq $Target) {
  $Target = "C:\Development Drive"
}

if (-not (Test-Path $Target)) {
  New-Item -Path $Target -ItemType Directory -Force
}

$SHELLDLL = "$env:SystemRoot\system32\shell32.dll"

New-Item -Path "HKCU:\Software\Classes\CLSID\$GUID"
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID" -Name "(Default)" -Value $Name -PropertyType String
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID" -Name "InfoTip" -Value $Name -PropertyType String
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID" -Name "System.IsPinnedToNameSpaceTree" -Value 0x00000001 -PropertyType DWORD
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID" -Name "SortOrderIndex" -Value 0x00000042 -PropertyType DWORD

New-Item -Path "HKCU:\Software\Classes\CLSID\$GUID\DefaultIcon"
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\DefaultIcon" -Name "(Default)" -Value $Icon -PropertyType ExpandString

New-Item -Path "HKCU:\Software\Classes\CLSID\$GUID\InProcServer32"
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\InProcServer32" -Name "(Default)" -Value $SHELLDLL -PropertyType ExpandString
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\InProcServer32" -Name "ThreadingModel" -Value "Both" -PropertyType String

New-Item -Path "HKCU:\Software\Classes\CLSID\$GUID\Instance"
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\Instance" -Name "CLSID" -Value "{0E5AAE11-A475-4c5b-AB00-C66DE400274E}" -PropertyType String

New-Item -Path "HKCU:\Software\Classes\CLSID\$GUID\Instance\InitPropertyBag"
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\Instance\InitPropertyBag" -Name "Attributes" -Value 0xf080004d -PropertyType DWORD
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\Instance\InitPropertyBag" -Name "TargetFolderPath" -Value $Target -PropertyType ExpandString

New-Item -Path "HKCU:\Software\Classes\CLSID\$GUID\ShellFolder"
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\ShellFolder" -Name "FolderValueFlags" -Value 0x00000228 -PropertyType DWORD
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\$GUID\ShellFolder" -Name "Attributes" -Value 0xf080004d -PropertyType DWORD

New-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID" -Name "(Default)" -Value $Name -PropertyType String
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID" -Name "InfoTip" -Value $Name -PropertyType String
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID" -Name "System.IsPinnedToNameSpaceTree" -Value 0x00000001 -PropertyType DWORD
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID" -Name "SortOrderIndex" -Value 0x00000042 -PropertyType DWORD

New-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\DefaultIcon"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\DefaultIcon" -Name "(Default)" -Value $Icon -PropertyType ExpandString

New-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\InProcServer32"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\InProcServer32" -Name "(Default)" -Value $SHELLDLL -PropertyType ExpandString
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\InProcServer32" -Name "ThreadingModel" -Value "Both" -PropertyType String

New-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\Instance"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\Instance" -Name "CLSID" -Value "{0E5AAE11-A475-4c5b-AB00-C66DE400274E}" -PropertyType String

New-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\Instance\InitPropertyBag"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\Instance\InitPropertyBag" -Name "Attributes" -Value 0xf080004d -PropertyType DWORD
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\Instance\InitPropertyBag" -Name "TargetFolderPath" -Value $Target -PropertyType ExpandString

New-Item -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\ShellFolder"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\ShellFolder" -Name "FolderValueFlags" -Value 0x00000228 -PropertyType DWORD
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Classes\CLSID\$GUID\ShellFolder" -Name "Attributes" -Value 0xf080004d -PropertyType DWORD

New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$GUID"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$GUID" -Name "(Default)" -Value $Name -PropertyType String

New-Item -Path "HKCU:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$GUID"
New-ItemProperty -Path "HKCU:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$GUID" -Name "(Default)" -Value $Name -PropertyType String

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name $GUID -Value 0x00000001 -PropertyType DWORD
