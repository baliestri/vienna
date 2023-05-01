$GnuPGPID = (Get-Process "gpg-agent" -ErrorAction SilentlyContinue).Id
$SSHPID = (Get-Process "ssh-agent" -ErrorAction SilentlyContinue).Id
$Starship = (Get-Command "starship" -ErrorAction SilentlyContinue)

if ($null -eq $GnuPGPID) {
  Start-Process "gpg-agent" -ArgumentList "--daemon" -WindowStyle Hidden
}

if ($null -eq $SSHPID) {
  Start-Process "ssh-agent" -ArgumentList "-s" -WindowStyle Hidden
}

if ($null -ne $Starship) {
  Invoke-Expression (&starship init powershell --print-full-init | Out-String)
}
