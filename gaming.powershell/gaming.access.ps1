$logFile = "C:\Users\sebas\gaming.access.log"
$timestampFile = "C:\Users\sebas\gaming.access.timestamp.txt"
"$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Script is starting" | Out-File -Append -FilePath $logFile

function activate {
    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Function activate is called" | Out-File -Append -FilePath $logFile
    try {
        net user kids /time:all
        $message = "User $username activated successfully."
        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) $message" | Out-File -Append -FilePath $logFile
    } catch {
        $errorMessage = "An error occurred while activating user kids: $_"
        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) $errorMessage" | Out-File -Append -FilePath $logFile
    }
}


function timer {
    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Function timer is called" | Out-File -Append -FilePath $logFile

    try {
        if (-not (Test-Path $timestampFile)) {
            # Si le fichier timestamp n'existe pas, le créer avec la date courante
            $currentTimestamp = (Get-Date -UFormat %s).Split(',')[0]
            $currentTimestamp | Out-File -FilePath $timestampFile -Force
            Write-Host "Timestamp file created. Calling activate function."
            activate
        } else {
            # Si le fichier timestamp existe, lire son contenu
            $timestampContent = Get-Content $timestampFile -Raw
            $currentTime = (Get-Date -UFormat %s).Split(',')[0]
            $contentIsInteger = [int]::TryParse($content, [ref]$null)

            if ($contentIsInteger) {
                # Si $content est un entier, vérifier la différence de temps
                $contentInSeconds = $content * 60
                $timeDifference = ([int]$timestampContent + [int]$contentInSeconds) - [int]$currentTime

                if ($timeDifference -ge 0) {
                    # Nous sommes toujours supérieurs à la date dans c:\timestamp.txt
                    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Il reste du temps ($($timeDifference / 60) minutes), let's continue" | Out-File -Append -FilePath $logFile
                } else {
                    # Nous sommes inférieurs à la date, attendre 5 minutes et appeler deactivate
                    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Fin du temps, let's deactivate" | Out-File -Append -FilePath $logFile
                    deactivate
                }
            } else {
                # Tout autre cas, afficher un message et appeler deactivate
                $errorMessage = "Le fichier timestamp a un problème ou la comparaison de date n'est pas possible, valeur de $content"
                "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) $errorMessage" | Out-File -Append -FilePath $logFile
                deactivate
            }
        }
    } catch {
        # Gérer les erreurs
        $errorMessage = "Une erreur s'est produite : $_"
        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) $errorMessage" | Out-File -Append -FilePath $logFile
        deactivate
    }
}


function deactivate {
    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Function deactivate is called" | Out-File -Append -FilePath $logFile
    try {
        # tester si la session de l'utilisateur est ouverte
        $activeSessions = quser | Out-String
        if ($activeSessions | Select-String -Pattern 'kids') {
            $sessionId = (quser | Where-Object { $_ -match 'kids' } | ForEach-Object { $_ -split '\s+' })[3]

            # Afficher un message à l'utilisateur
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Windows message sent on kids session" | Out-File -Append -FilePath $logFile
            msg kids "ATTENTION : La session sera fermée dans 5 minutes. Veuillez sauvegarder votre travail !!!!!!!!!!"

            # Attendre pendant 5 minutes (300 secondes)
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Wait 5 minutes" | Out-File -Append -FilePath $logFile
            Start-Sleep -Seconds 300

            # Réinitialiser les heures d'accs pour l'utilisateur
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) stop session access for kids" | Out-File -Append -FilePath $logFile
            net user kids /time:

            # Fermer la session de l'utilisateur
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) logoff kids" | Out-File -Append -FilePath $logFile
            logoff $sessionId
        }
        else {
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Pas de session active avec kids : contenu des sessions pour debug : $activeSessions" | Out-File -Append -FilePath $logFile
        }

        # Ecrire 0 dans le fichier gaming.access.txt sur la dropbox (seulement si $content ne vaut pas 0)
        if ($content -ne 0) {
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Write O in gaming.access.txt on Dropbox" | Out-File -Append -FilePath $logFile
            $tempFile = "C:\Users\sebas\gaming.access.tmp"
            "0" | Out-File -encoding ascii -FilePath $tempFile -NoNewline
            $refresh_token = 'KEEPASS'
            $client_id = 'ACCESS_KEY'
            $client_secret = 'SECRET_KEY'
            $result = Invoke-RestMethod -Uri 'https://api.dropbox.com/oauth2/token' -Method Post -Body @{
                grant_type='refresh_token'
                refresh_token="$refresh_token"
                client_id="$client_id"
                client_secret="$client_secret"
            }
            $accessToken = $result | Select-Object -ExpandProperty access_token
            Invoke-RestMethod -Method Post -Uri "https://content.dropboxapi.com/2/files/upload" -Headers @{
                    Authorization = "Bearer $accessToken"
                    "Content-Type" = "application/octet-stream"
                    "Dropbox-API-Arg" = '{"path": "/KIDS/gaming.access.txt","mode":"overwrite"}'
                } -InFile $tempFile

            Remove-Item $tempFile
        }

        if (Test-Path $timestampFile) {
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Supprimer le fichier timestamp" | Out-File -Append -FilePath $logFile
            Remove-Item $timestampFile
        }
        
        $message = "User kids deactivated successfully."
        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) $message" | Out-File -Append -FilePath $logFile

    } catch {
        $errorMessage = "An error occurred while deactivating user kids: $_"
        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) $errorMessage" | Out-File -Append -FilePath $logFile
        # Vous pouvez ajouter un enregistrement dans un fichier de journal ici si nécessaire
    }
}



while ($true) {
    try {
        $url = "https://www.dropbox.com/scl/fi/devpfjq44jllvxbcb6ssy/gaming.access.txt?rlkey=4jyoenvfrxggox276k8aawjls&dl=1"
        $content = Invoke-RestMethod -Uri "$url"

        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) *************************************" | Out-File -Append -FilePath $logFile
        "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) Start of loop : Content value : $content" | Out-File -Append -FilePath $logFile

        switch ($content) {
            "y" {
                activate
            }
            {$_ -ge 1 -and $_ -le 1000} {
                activate
                timer
            }
            default {
                deactivate
            }
        }
    } catch {
        Write-Host "Une erreur s'est produite : $_"
    }

    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) End of loop : let's wait one minute then loop again" | Out-File -Append -FilePath $logFile
    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) ---------------------------------------------------" | Out-File -Append -FilePath $logFile
    Start-Sleep -Seconds 60  # Attendez 60 secondes avant la prochaine itération
}
