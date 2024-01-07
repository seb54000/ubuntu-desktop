
Sur PC gaming depuis ssh

Remove-Item C:\ProgramData\chocolatey\* -Recurse -Force
Remove-Item C:\ProgramData\chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install nano


install SSH through powershell - lancer une invit de commande ne mode admin
https://4sysops.com/archives/installing-openssh-on-windows-10-1803-and-higher-and-server-2019/#rtoc-5

Get-WindowsCapability -Online | ? name -like *OpenSSH.Server* | Add-WindowsCapability -Online

Set-Service sshd -StartupType Automatic
Start-Service sshd
Get-Service -Name *ssh* | select DisplayName, Status, StartType
Get-NetFirewallRule -Name *SSH*



nano gaming.access.ps1






Créer le service windows
$(Get-Command powershell.exe).Source


New-Service -Name "gaming.access.service" -BinaryPathName "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\Users\sebas\gaming.access.ps1" -DisplayName "gaming.access.service" -StartupType Automatic
Start-Service -Name "gaming.access.service"
Get-Service -Name *gaming* | select DisplayName, Status, StartType






Ceci ne marche pas on va utiliser la solution avec NSSM
https://nssm.cc/ - https://www.it-connect.fr/comment-executer-un-script-powershell-comme-service/

choco install nssm -y
$PathNSSM = (Get-Command NSSM).Source
$PathPowerShell = (Get-Command Powershell).Source
$PathScript = "C:\Users\sebas\gaming.access.ps1"
$ServiceName = "gaming.access.service"
$ServiceArguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $PathScript
& $PathNSSM install $ServiceName $PathPowerShell $ServiceArguments
Start-Service -Name "gaming.access.service"
& $PathNSSM status $ServiceName
Get-Service -Name *gaming* | select DisplayName, Status, StartType
Get-Service $ServiceName



  814  sudo systemctl disable kids_game_timer
  815  sudo rm /usr/bin/kids_game_timer.sh
  816  sudo rm /etc/systemd/system/kids_game_timer.service
  820  sudo systemctl daemon-reload
  824  systemctl reset-failed
  825  sudo systemctl status kids_game_timer --no-pager






tail -f powershell equivalent
Get-Content -Path 'gaming.access.log' -wait



TODO : créer des alertes par email
TODO : vérifier la taille du fichier de log et l'effacer quand il dépasse 100 Mo par exemple



