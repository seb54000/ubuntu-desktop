#!/bin/bash

timer_file="/home/seb/Dropbox/KIDS/kids_game_timer.txt"
    # timer contient un nombre de minutes
authorized_file="/home/seb/Dropbox/KIDS/kids-account-config.txt"
timestamp_file="/home/seb/Dropbox/KIDS/kids_game_timestamp.txt"


# Check dropboxes are running (if not start them)
ps -efw | grep -e \/seb\/.dropbox-dist | grep -v grep > /tmp/droptest
grep -e dropbox-dist /tmp/droptest
if [ "$?" -ne "0" ]; then
	echo "Dropbox Seb is not running, start it"
	set -e
	/usr/bin/dropbox start > /dev/null
	set +e
	sleep 15
fi
sudo rm -f /tmp/droptest


reset_remove () {
    echo "reset_remove() time is finished or timer has 0 value or timer contains not only numbers"
    echo "0" > "$authorized_file"
    echo "0" > "$timer_file"
    rm -f $timestamp_file
}

while true
do
    # Lire le contenu du fichier /tmp/timer
    timer_value=$(cat "$timer_file")
    echo "debug timer_value is : $timer_value"

    if [[ "$timer_value" == "M" ]]; then
    # Si timer_value contient M, on est en mode manuel donc on ne fait rien
    echo "Manual mode, doing nothing..."
    # Just remove timestamp file in case we switch abruptely in mnaual mode
    rm -f $timestamp_file
    else
        # Vérifier si timer est un nombre entier
        if [[ "$timer_value" =~ ^[0-9]+$ ]]; then

            if [ "$timer_value" -gt 0 ]; then
                # Écrire la valeur 1 dans /tmp/authorized -- à partir de ce moment là, le host gaming va autoriser l'accès
                echo "1" > "$authorized_file"
                
                # Vérifier si le timestamp existe déjà
                if [ ! -e "$timestamp_file" ]; then
                    # Si non, générer un nouveau timestamp
                    echo "Time allowed for $timer_value minutes"
                    timestamp=$(date +%s)
                    echo "$timestamp" > "$timestamp_file"
                fi

                # Vérifier si le temps écoulé est supérieur à la durée autorisée (rappel timer est en minutes)
                current_time=$(date +%s)
                expiration_time=$((timestamp + timer_value * 60))

                if [ "$current_time" -gt "$expiration_time" ]; then
                    # Si le temps est dépassé, mettre 0 dans /tmp/authorized et /tmp/timer
                    echo "Time is finished"
                    reset_remove
                else
                    echo "Time is still running, enjoy"
                fi
            else
                # Le timer contient 0 on reset
                reset_remove
            fi
        else
            # Le timer contient autre chose que des chiffres, on reset
            reset_remove
        fi
    fi
    # Attendre 120 secondes avant la prochaine boucle
    sleep 120
done
