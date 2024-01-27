#!/bin/bash

while true
do
    CONTENT=$(curl -sL "https://www.dropbox.com/scl/fi/9ycqd2aq50ofp10s79hy6/librelec.txt?rlkey=a2kwbfl5qdt1lun7hf4y6n57x&dl=0")
    if [ ${CONTENT} == "1" ]; then
        # Try to find true for masterLock at start in advancedsettings
        grep -q true /storage/.kodi/userdata/advancedsettings.xml
        if [ $? -eq 0 ]; then
            echo "la valeur est actuellement a true et on veut la passer à false"
            sed -i s/true/false/ /storage/.kodi/userdata/advancedsettings.xml
            reboot
        fi
    else
        grep -q false /storage/.kodi/userdata/advancedsettings.xml
        if [ $? -eq 0 ]; then
            echo "la valeur est actuellement a false et on veut la passer à true"
            sed -i s/false/true/ /storage/.kodi/userdata/advancedsettings.xml
            reboot
        fi
    fi

    # Check and relaunch docker containers for transmission if they are down
    /storage/.kodi/addons/service.system.docker/bin/docker ps | grep -q transmission-openvpn-core
    if [ $? -ne 0 ]; then
        echo "restart transmission-openvpn-core"
        /storage/.kodi/addons/service.system.docker/bin/docker restart transmission-openvpn-core
    fi
    /storage/.kodi/addons/service.system.docker/bin/docker ps | grep -q transmission-openvpn-proxy
    if [ $? -ne 0 ]; then
        echo "restart transmission-openvpn-proxy"
        /storage/.kodi/addons/service.system.docker/bin/docker restart transmission-openvpn-proxy
    fi

    sleep 30
done

