#!/bin/bash

echo "Install and setup access_service"

sudo cp access_service/access_service.sh /usr/bin/access_service.sh
sudo cp access_service/access_service.service /etc/systemd/system/access_service.service
sudo systemctl enable access_service
sudo systemctl restart access_service
sudo systemctl status access_service --no-pager


echo "Install and setup Squid Proxy + config users"
# https://steelmon.wordpress.com/2010/12/09/setting-up-a-blacklist-proxy-with-automatic-updates-using-squid-and-squidguard/
# https://webhostinggeeks.com/howto/how-to-configure-squid-proxy-server-for-parental-controls/#:~:text=You%20can%20configure%20Squid%20for,internet%20access%20during%20certain%20hours.
# https://doc.ubuntu-fr.org/tutoriel/comment_mettre_en_place_un_controle_parental

sudo apt-get install squidguard
sudo cp /etc/squidguard/squidGuard.conf /etc/squidguard/squidGuard.conf.orig
sudo cp squid/squidguard.conf /etc/squidguard/squidGuard.conf
# wget https://steelmon.files.wordpress.com/2010/12/getlists.odt
sudo cp squid/getlists.sh  /usr/local/bin/getlists.sh
sudo chmod +x /usr/local/bin/getlists.sh

sudo getlists.sh
# ls -l /var/lib/squidguard/db/blacklists/

# TODO investigate the getlists script ???
# tar: blacklists/porn: Cannot create symlink to ‘adult’: File exists
# blacklists/proxy
# tar: Exiting with failure status due to previous errors

# TO SEE LATER how to improve but it is due to these lines for new adult blacklist from toulous
# tar -C ${BLKDIRADLT} -xvzf ${BLACKDIR}/${UNIQUEDT}_fr.tar.gz
# perl -pi -e "s#^\-##g" ${BLKDIRADLT}/adult/domains
# perl -pi -e "s#^\-##g" ${BLKDIRADLT}/adult/urls



#  Compile SquidGuard DB
sudo squidGuard -C all

# Set a cron (3 in the morning ??? are you sure for a desktop) to update the blacklist
# Should find someting like on MacOS to launch the job at startup if it had not run for a while
# 30 3 * * * /usr/local/bin/getlists.sh

sudo apt install -y squid net-tools
sudo snap install curl
# Check if systemd service is enabled
systemctl is-enabled squid

grep -qxF 'url_rewrite_program /usr/bin/squidGuard -c /etc/squid/squidGuard.conf' /etc/squid/squid.conf || echo 'url_rewrite_program /usr/bin/squidGuard -c /etc/squid/squidGuard.conf' | sudo tee -a /etc/squid/squid.conf > /dev/null
grep -qxF 'acl bad_urls dstdomain "/etc/squid/bad_urls.acl"' /etc/squid/squid.conf || echo 'acl bad_urls dstdomain "/etc/squid/bad_urls.acl"' | sudo tee -a /etc/squid/squid.conf > /dev/null
grep -qxF 'http_access deny bad_urls' /etc/squid/squid.conf || echo 'http_access deny bad_urls' | sudo tee -a /etc/squid/squid.conf > /dev/null

echo 'www.google.fr' | sudo tee /etc/squid/bad_urls.acl > /dev/null
https_proxy=http://localhost:3128 curl https://www.google.fr

sudo systemctl reload squid


sudo systemctl reload squid

# cat /var/log/squidguard/suidgard.log
https_proxy=http://localhost:3128 curl -kv https://xhamster.com


# CHROMIUM
# https://github.com/seb54000/tp-centralesupelec/blob/c0ca88e1cdf82e9479890e28f3b040baad10181f/tf-ami-vm/user_data_tpiac.sh#L111

echo "Create users and GNOME session settings + browser"


set_gsettings () {
    USERNAME=$1
    LOCAL_UID=$(id -u ${USERNAME})

    # Proxy
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.system.proxy mode 'manual'"
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.system.proxy.http host 'localhost'"
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.system.proxy.https host 'localhost'"
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.system.proxy.http port '3128'"
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.system.proxy.https port '3128'"

    # https://askubuntu.com/questions/1183009/manage-dash-to-dock-favorite-apps-by-command-line
    # Dock
    # Origin
    # ['firefox_firefox.desktop', 'thunderbird.desktop', 'org.gnome.Nautilus.desktop', 'rhythmbox.desktop', 'libreoffice-writer.desktop', 'snap-store_ubuntu-software.desktop', 'yelp.desktop', 'google-chrome.desktop', 'code_code.desktop']
    APP_LIST="['org.gnome.Nautilus.desktop', 'libreoffice-writer.desktop', 'snap-store_ubuntu-software.desktop', 'google-chrome.desktop', 'code_code.desktop', 'seb.gnome-network-displays.desktop']"
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.shell favorite-apps \"${APP_LIST}\""
    sudo -H -u ${USERNAME} bash -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${LOCAL_UID}/bus gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false"
    
}
set_gsettings theo


# gsettings very powerful to set gnome settings by command line
# https://manpages.ubuntu.com/manpages/trusty/en/man1/gsettings.1.html

sudo -H -u seb bash -c 'echo "I am $USER, with uid $UID"'

# Remove firefox - set only chormium as a web-browser with restriction in file mode ?

# gsettings set org.gnome.system.proxy mode "none"
# gsettings set org.gnome.system.proxy.https host ""
# gsettings set org.gnome.system.proxy.https port ""


echo "Auto startup programs in GNOME session + dock customization and shortcuts"

# https://linuxconfig.org/how-to-customize-dock-panel-on-ubuntu-22-04-jammy-jellyfish-linux


# AUTOSTART
# https://github.com/seb54000/tp-centralesupelec/blob/c0ca88e1cdf82e9479890e28f3b040baad10181f/tf-ami-vm/user_data_tpiac.sh#L123


echo "set automount at startup fetaures"
# https://wiki.ubuntu.com/MountWindowsSharesPermanently
# Note the very interesting usage of credentials file to avoid putting everything in the fstab file


sudo apt-get install cifs-utils
# Create a smb credentials file with limited access
cat <<EOF > /var/tmp/.doux.smb.credentials
username=${DOUX_SMB_USERNAME}
password=${DOUX_SMB_PASSWORD}
EOF
sudo mv /var/tmp/.doux.smb.credentials /etc/.doux.smb.credentials
sudo chmod 600 /etc/.doux.smb.credentials

sudo mkdir -p /mnt/films
grep -qF '//local.nas.multiseb.com/home/films' /etc/fstab || echo '//local.nas.multiseb.com/home/films /mnt/films cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8 0 0' | sudo tee -a /etc/fstab > /dev/null

sudo mount -a


# TODO Create a folder on NAS for backup / HOME directory and mount theri HOME dir on it
# + a second one for DATAs


echo "LAPTOP only - Disable the touch screen ???"


echo "Screen cast to PicoPix Max projector (or others)"
# We need gnome network display (only distributed through flatpak)
sudo apt install -y flatpak gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub org.gnome.NetworkDisplays

# Command to run
# flatpak run org.gnome.NetworkDisplays
# ls /usr/share/applications/

# https://www.cyberciti.biz/howto/how-to-install-and-edit-desktop-files-on-linux-desktop-entries/

cat <<EOF > /var/tmp/seb.gnome-network-displays.desktop
[Desktop Entry]
Name=network displays
GenericName=GNOME Network Displays
Comment=Manage screencast to external display (like projector, chrome cast, ...)
Exec=flatpak run org.gnome.NetworkDisplays

## State the name of the icon that will be used to display this entry ##
Icon=usb-creator-gtk
Terminal=false
Type=Application

## States the categories in which this entry should be shown menu ##
# Categories=System;Settings;GTK;HardwareSettings;
# X-Ubuntu-Gettext-Domain=usbcreator
EOF

# desktop-file-validate /var/tmp/seb.gnome-network-displays.desktop
# sudo desktop-file-install --dir=~/usr/share/applications/ /var/tmp/seb.gnome-network-displays.desktop
# sudo update-desktop-database /usr/share/applications
sudo cp /var/tmp/seb.gnome-network-displays.desktop /usr/share/applications/

#  FOr later if airplay / appleTV is needed, there is an openAirplay project
# https://askubuntu.com/questions/819199/how-do-i-share-my-screen-to-airplay-appletv


echo "DESKTOP only - install docker and transmission configuration (not on laptop)"

# >Test variable présence DESKTOP_INSTALL=1 



echo "DESKTOP only - install KODI and configuration on NAS (not on laptop)"


