#!/bin/bash

# Remplacez les valeurs suivantes par celles de votre proxy
proxy_host="localhost"
proxy_port="3128"

# Exclure l'utilisateur XXX
exclude_user="seb"

# Récupérer le nom de l'utilisateur actuel
current_user=$(whoami)

# Vérifier si l'utilisateur actuel est celui à exclure
if [ "$current_user" != "$exclude_user" ]; then
    # Définir les paramètres du proxy pour GNOME
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.http host "$proxy_host"
    gsettings set org.gnome.system.proxy.http port "$proxy_port"
    gsettings set org.gnome.system.proxy.https host "$proxy_host"
    gsettings set org.gnome.system.proxy.https port "$proxy_port"
    gsettings set org.gnome.system.proxy.ftp host "$proxy_host"
    gsettings set org.gnome.system.proxy.ftp port "$proxy_port"
    gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.1']"

    APP_LIST="['org.gnome.Nautilus.desktop', 'libreoffice-writer.desktop', 'libreoffice-impress.desktop', 'snap-store_ubuntu-software.desktop', 'google-chrome.desktop', 'code_code.desktop', 'seb.gnome-network-displays.desktop']"
    # https://askubuntu.com/questions/1183009/manage-dash-to-dock-favorite-apps-by-command-line
    gsettings set org.gnome.shell favorite-apps "${APP_LIST}"
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

    # Afficher les paramètres pour vérification
    echo "Paramètres du proxy configurés :"
    gsettings get org.gnome.system.proxy mode
    gsettings get org.gnome.system.proxy.http host
    gsettings get org.gnome.system.proxy.http port
    gsettings get org.gnome.system.proxy.https host
    gsettings get org.gnome.system.proxy.https port
    gsettings get org.gnome.system.proxy.ftp host
    gsettings get org.gnome.system.proxy.ftp port
    gsettings get org.gnome.system.proxy ignore-hosts
else
    echo "L'utilisateur $exclude_user est exclu de la configuration du proxy."
fi
