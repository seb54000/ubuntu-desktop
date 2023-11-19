#!/bin/bash

remove_access () {
    USERNAME=$1
    LOCAL_UID=$(id -u ${USERNAME})
    sudo usermod -s /usr/sbin/nologin ${USERNAME}
    sudo usermod -L ${USERNAME}
    # https://fostips.com/log-out-command-linux-desktops/
    
    # Test if a GNOME session is active and get the DISPLAY then kill
    sudo loginctl -a show-user ${USERNAME}
    if [ $? -eq 0 ]; then
        LOCAL_DISPLAY=$(sudo loginctl -a show-user ${USERNAME} | grep Display | sed 's/Display.//g')
        sudo -H -u ${USERNAME} bash -c "DISPLAY=:${LOCAL_DISPLAY} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gnome-session-quit --force"
    fi


loginctl show-session $(sudo loginctl -a show-user ${USERNAME} | grep Display) | sed 's/Display.//g' | grep Display

}

allow_access () {
    USERNAME=$1
    sudo usermod -s /usr/bin/bash ${USERNAME}
    sudo usermod -U ${USERNAME}
}

log () {
    echo "$(date +%Y%m%d-%H%M%S) $1" >> /var/log/access_service.log
}


while true
do
    # Test if an internet connexion is available
    wget -q --spider http://google.com

    if [ $? -eq 0 ]; then
        # log "Online, will check the dropbox value"
        CONTENT=$(curl -L "https://www.dropbox.com/scl/fi/plvgi8cqnmrl5sjxpw8pr/ubuntu-desktop.txt?rlkey=xu4ns2tn1j89d9147hjj5ei6o&dl=0")
        if [ $CONTENT == "1" ]; then
            log "Online, value=1, will allow access"
            allow_access theo
            allow_access leo
        else
            log "Online, value=0 or != from 1, will remove access and kill session if already started"
            remove_access theo
            remove_access leo
        fi
    else
        log "Offline (no internent access), we prefer remove access"
        remove_access theo
        remove_access leo
    fi
    sleep 30
done

# To know the status of a user at linux level
# sudo passwd -S -a | grep theo
# If the letter after name is L=locked, otherwise P)

# To list session from a GNOME perspective
# loginctl