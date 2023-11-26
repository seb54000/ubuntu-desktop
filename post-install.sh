#!/bin/bash

set -e

handle_error() {
  echo "An error occurred. Exiting."
  exit 1
}

cleanup() {
    echo “Performing cleanup tasks…”
    # Your cleanup logic here
}

trap handle_error ERR
trap cleanup EXIT



# TODO check if .env file do not exists, stop (as we will have problem later like removing of credentials in smb credentials)
source .env

set -x

/usr/bin/bash $(dirname $0)/user_mgmt/create_user.sh

echo "Manage sudo rights for seb user"
[ -f /etc/sudoers.d/seb ] || echo "seb ALL=(ALL) NOPASSWD:ALL" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/seb')


echo "install Vscode"
sudo snap install code --classic

# TODO open current folder in VScode with accepting / trusting 

echo "Install VLC client"
sudo snap install vlc

echo "Install Google chrome"
[ -f /usr/bin/google-chrome ] || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo dpkg -i ./google-chrome*.deb && \
    rm ./google-chrome*.deb

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

sudo apt-get install -y squidguard
# Blacklist DL : https://dsi.ut-capitole.fr/blacklists/download/
sudo cp /etc/squidguard/squidGuard.conf /etc/squidguard/squidGuard.conf.orig
sudo cp squid/squidguard.conf /etc/squidguard/squidGuard.conf
# wget https://steelmon.files.wordpress.com/2010/12/getlists.odt
sudo cp squid/getlists.sh  /usr/local/bin/getlists.sh
sudo chmod +x /usr/local/bin/getlists.sh

sudo getlists.sh
# ls -l /var/lib/squidguard/db/blacklists/

# Define a service with timer to run the job daily
sudo cp squid/systemd.service /etc/systemd/system/getlist.service
sudo cp squid/systemd.timer /etc/systemd/system/getlist.timer
sudo systemctl enable getlist.service
sudo systemctl start getlist.service
sudo systemctl enable getlist.timer
sudo systemctl start getlist.timer

sudo apt install -y squid net-tools
sudo snap install curl
# Check if systemd service is enabled
systemctl is-enabled squid


# TODOO - only once for tte squid.conf.roig (if already exists don't do it again)
# sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
echo -e '.youtube.com\n.tiktok.com\n.scratch.mit.edu\n.mess.eu.org\n.buildnowgg.co\.nminiroyale.io' | sudo tee /etc/squid/bad_urls.acl > /dev/null
sudo cp squid/squid.conf /etc/squid/squid.conf
sudo cp squid/error.html /etc/squid/error.html
sudo cp squid/squid.custom.conf /etc/squid/conf.d/squid.custom.conf
sudo systemctl reload squid
# sudo chmod 666 /var/log/squid/squidGuard.log 

# https_proxy=http://localhost:3128 curl https://www.google.fr
# # cat /var/log/squidguard/suidgard.log
# https_proxy=http://localhost:3128 curl -kv https://scratch.mit.edu
# https_proxy=http://localhost:3128 curl -kv https://xhamster.com
# echo “https://xhamster.com / - - GET” | sudo squidGuard -c /etc/squidguard/squidGuard.conf -d

# https://michauko.org/blog/squidguard-filtre-durl-et-listes-a-jour-le-plus-dur-313/


# CHROMIUM
# https://github.com/seb54000/tp-centralesupelec/blob/c0ca88e1cdf82e9479890e28f3b040baad10181f/tf-ami-vm/user_data_tpiac.sh#L111

echo "Configure proxy in GNOME for users through setting an autostart script"

sudo cp squid/configure_proxy.sh /usr/local/bin/configure_proxy.sh
sudo chmod +x /usr/local/bin/configure_proxy.sh
sudo cp squid/configure_proxy.desktop /etc/xdg/autostart/configure_proxy.desktop
sudo chmod +x /etc/xdg/autostart/configure_proxy.desktop


# TODO avoid user to change proxy settings or network settings
# https://askubuntu.com/questions/283142/how-can-i-restrict-users-fom-changing-network-settings-and-adding-new-connection



echo "Auto startup programs in GNOME session + dock customization and shortcuts"

# https://linuxconfig.org/how-to-customize-dock-panel-on-ubuntu-22-04-jammy-jellyfish-linux

# AUTOSTART
# https://github.com/seb54000/tp-centralesupelec/blob/c0ca88e1cdf82e9479890e28f3b040baad10181f/tf-ami-vm/user_data_tpiac.sh#L123


echo "set automount at startup fetaures"
# https://wiki.ubuntu.com/MountWindowsSharesPermanently
# Note the very interesting usage of credentials file to avoid putting everything in the fstab file


sudo apt-get install -y cifs-utils
# Create a smb credentials file with limited access
cat <<EOF > /var/tmp/.doux.smb.credentials
username=${DOUX_SMB_USERNAME}
password=${DOUX_SMB_PASSWORD}
EOF
cat <<EOF > /var/tmp/.famille.smb.credentials
username=${FAMILLE_SMB_USERNAME}
password=${FAMILLE_SMB_PASSWORD}
EOF
cat <<EOF > /var/tmp/.douce.smb.credentials
username=${DOUCE_SMB_USERNAME}
password=${DOUCE_SMB_PASSWORD}
EOF
cat <<EOF > /var/tmp/.bestphotos.smb.credentials
username=${BEST_SMB_USERNAME}
password=${BEST_SMB_PASSWORD}
EOF
sudo mv /var/tmp/.doux.smb.credentials /etc/.doux.smb.credentials
sudo chmod 600 /etc/.doux.smb.credentials
sudo chown root:root /etc/.doux.smb.credentials
sudo mv /var/tmp/.famille.smb.credentials /etc/.famille.smb.credentials
sudo chmod 600 /etc/.famille.smb.credentials
sudo chown root:root /etc/.famille.smb.credentials
sudo mv /var/tmp/.douce.smb.credentials /etc/.douce.smb.credentials
sudo chmod 600 /etc/.douce.smb.credentials
sudo chown root:root /etc/.douce.smb.credentials
sudo mv /var/tmp/.bestphotos.smb.credentials /etc/.bestphotos.smb.credentials
sudo chmod 600 /etc/.bestphotos.smb.credentials
sudo chown root:root /etc/.bestphotos.smb.credentials


sudo mkdir -p /mnt/films
grep -qF '/mnt/films' /etc/fstab || echo "//local.nas.multiseb.com/home/films /mnt/films cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir -p /mnt/nas/doux
grep -qF '/mnt/nas/doux' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/doux cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir -p /mnt/nas/douce
grep -qF '/mnt/nas/douce' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/douce cifs credentials=/etc/.douce.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir -p /mnt/nas/bestphotos
grep -qF '/mnt/nas/bestphotos' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/bestphotos cifs credentials=/etc/.bestphotos.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir -p /mnt/nas/famille
grep -qF '/mnt/nas/famille' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/famille cifs credentials=/etc/.famille.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
# sudo mkdir -p /mnt/theo_home_dir
sudo mkdir -p /home/theo/network_share
grep -qF 'theo_home_dir' /etc/fstab || echo "//local.nas.multiseb.com/home/theo_home_dir /home/theo/network_share cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u theo),gid=$(id -g theo),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
# sudo mkdir -p /mnt/leo_home_dir
# grep -qF 'leo_home_dir' /etc/fstab || echo "//local.nas.multiseb.com/home/leo_home_dir /home/leo cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u leo),gid=$(id -g leo),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir -p /mnt/triphotos
grep -qF '/mnt/triphotos' /etc/fstab || echo "//local.nas.multiseb.com/home/Drive/Moments /mnt/triphotos cifs credentials=/etc/.famille.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mkdir -p /mnt/backup
grep -qF '/mnt/backup' /etc/fstab || echo "//local.nas.multiseb.com/home/ubuntu_backups /mnt/backup cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null


sudo mount -a


echo "LAPTOP only - Disable the touch screen ???"
# Huawei only

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

if [ ${DESKTOP_INSTALL} == "1" ]; then
    sudo snap install docker
    sudo groupadd docker
    # sudo usermod -aG docker seb
    sudo gpasswd -a seb docker 
    sudo chmod 666 /var/run/docker.sock

    docker run --cap-add=NET_ADMIN -d \
    --restart unless-stopped \
    --mount type=bind,source=/mnt/films/seedbox,target=/data \
    --mount type=bind,source=/mnt/films/seedbox/config,target=/config \
    --mount type=bind,source=/mnt/films/seedbox/ubuntu_seedbox_openvpn,target=/etc/openvpn/custom/ \
    -e OPENVPN_PROVIDER=custom \
    -e OPENVPN_CONFIG=openvpn \
    -e OPENVPN_USERNAME=5DRFhMFyXF \
    -e OPENVPN_PASSWORD=3tnyyYCf3Q \
    -e DEBUG=true \
    -p 9999:9091 \
    -e LOCAL_NETWORK=192.168.0.0/16 \
    --log-driver json-file \
    --log-opt max-size=10m \
    --name transmission-openvpn \
    haugene/transmission-openvpn


    docker run -d \
      --restart unless-stopped \
      --link transmission-openvpn:transmission \
      -p 8080:8080 \
      --name transmission-openvpn-proxy \
      haugene/transmission-openvpn-proxy  


fi



echo "DESKTOP only - install KODI and configuration on NAS (not on laptop)"

if [ ${DESKTOP_INSTALL} == "1" ]; then
    sudo apt install -y kodi
    # TODO for each user 
    mkdir -p /home/seb/.kodi
    # fstab line with uid / gid
    grep -qF '/home/seb/.kodi' /etc/fstab || echo "//local.nas.multiseb.com/home/films/kodi_datas /home/seb/.kodi cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
    # https://kodi.wiki/view/Kodi_data_folder
fi


echo "Install Keepass and launch with a shared DB on NAS"
sudo apt install -y keepassxc
    # TODO add keepass to favorites in GNOME
    # TODO need an rsync with google drive

    # Keepass is ubuntu_keepass in /mnt/doux
    # https://www.padok.fr/en/blog/ssh-keys-keepassxc

if [ ${DESKTOP_INSTALL} == "1" ]; then
    echo "Install SSH"
    # Only available through locla network as firewaal on freebox do not forward port
    sudo apt install ssh -y

    # Generate a key and back it up in the keepass
    # ssh-keygen -C ubuntu-desktop-doux-key

    # Accept the key for connexion in authorized_keys
    echo ${UBUNTU_DESKTOP_DOUX_KEY} > /home/seb/.ssh/authorized_keys

fi

echo "Install Remmina"
sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next
sudo apt update -y
sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-secret

# TODO add remmina in favorites in GNOME

# TODO create remmina config as command line
# https://askubuntu.com/questions/1374673/add-a-rdp-remmina-host-by-command-line

# TODO debug RDP isntll for desktop
# https://www.digitalocean.com/community/tutorials/how-to-enable-remote-desktop-protocol-using-xrdp-on-ubuntu-22-04

if [ ${DESKTOP_INSTALL} == "1" ]; then

    echo "install XRDP"

    sudo apt install xrdp -y
    sudo systemctl enable xrdp
    # sudo usermod -a -G ssl-cert xrdp
    sudo systemctl restart xrdp
fi


if [ ${GALAXY_INSTALL} == "1" ]; then

    echo "install Gthumb"
    sudo apt install -y gthumb
    sudo apt install -y exiftool

    # TODO add gthumb in favorites in GNOME
    # TODO manage rating shortcuts with custom actions laucnhing exiftool script
    # https://gitlab.gnome.org/GNOME/gthumb/-/issues/82
    # https://github.com/GNOME/gthumb/tree/master
    # TODO Define custom filter in browser view for rating - 

    # # TODO add bookmark through command line (for /mnt/triphotos)
    #  cat $hOME/.config/gthumb/bookmarks.xbel 
    # seb@seb-KLVC-WXX9:~/ubuntu-desktop$ cat ../.config/gthumb/bookmarks.xbel 
    # <?xml version="1.0" encoding="UTF-8"?>
    # <xbel version="1.0"
    #       xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks"
    #       xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info"
    # >
    #   <bookmark href="file:///mnt/doux/Drive/Moments/2022/02" added="2023-11-19T12:12:28.718878Z" modified="2023-11-19T12:12:28.718893Z" visited="2023-11-19T12:12:28.718881Z">
    #     <info>
    #       <metadata owner="http://freedesktop.org">
    #         <bookmark:applications>
    #           <bookmark:application name="gThumb" exec="&apos;gthumb %u&apos;" modified="2023-11-19T12:12:28.718888Z" count="1"/>
    #         </bookmark:applications>
    #         <bookmark:private/>
    #       </metadata>
    #     </info>
    #   </bookmark>

    echo "Install dropbox with double install"
    # https://askubuntu.com/questions/475419/how-to-link-and-use-two-or-more-dropbox-accounts-simultaneously
    mkdir -p "$HOME"/.dropbox-carole

    # TO configure /start : export HOME="/home/seb/.dropbox-carole" && /usr/bin/dropbox start -i
    # WARNING seems it doesn't work when command is launched from vscode terminal...
    # TODO add this command to bahs_rc or set a service to start this when not working anymore...


    sudo apt install -y nautilus-dropbox
    #  /usr/bin/dropbox start -i

    echo "INstalling WhatsApp" 
    # https://github.com/eneshecan/whatsapp-for-linux
    sudo snap install whatsapp-for-linux

    echo "Define favorites for seb user"

    export APP_LIST="['org.gnome.Nautilus.desktop', 'libreoffice-writer.desktop', 'libreoffice-impress.desktop', 'snap-store_ubuntu-software.desktop', 'google-chrome.desktop', 'code_code.desktop', 'org.remmina.Remmina.desktop', 'seb.gnome-network-displays.desktop', 'org.gnome.gThumb.desktop']"
    gsettings set org.gnome.shell favorite-apps "${APP_LIST}"


    # echo "installing gmail desktop app"
    # sudo snap install gmail-desktop
    # TODO test thunderbird ?
    sudo snap remove -y gmail-desktop

    sudo snap install gnome-contacts
    # TODO manage synchronisation ??

    sudo snap install audacity
    sudo snap connect audacity:alsa

    sudo snap install teams-for-linux

    echo "INstalling import photos scripts"

    sudo apt-get -y install msmtp
    envsubst < import_photos/msmtp.conf > /var/tmp/msmtp.conf.subst
    sudo mv /var/tmp/msmtp.conf.subst /etc/msmtprc
    sudo chown root:root /etc/msmtprc
    sudo chmod 600 /etc/msmtprc


    sudo cp import_photos/import-photos.sh  /usr/local/bin/import-photos.sh
    sudo chmod +x /usr/local/bin/import-photos.sh
    sudo cp import_photos/import-photos-mail.sh  /usr/local/bin/import-photos-mail.sh
    sudo chmod +x /usr/local/bin/import-photos-mail.sh
    sudo cp import_photos/import-photos-rating-dispatch.sh  /usr/local/bin/import-photos-rating-dispatch.sh
    sudo chmod +x /usr/local/bin/import-photos-rating-dispatch.sh

    sudo cp import_photos/systemd.service /etc/systemd/system/import-photo-mail.service
    sudo cp import_photos/systemd.timer /etc/systemd/system/import-photo-mail.timer
    sudo systemctl enable import-photo-mail.service
    sudo systemctl start import-photo-mail.service
    sudo systemctl enable import-photo-mail.timer
    sudo systemctl start import-photo-mail.timer

    # sudo systemctl daemon-reload
    # sudo systemctl restart import-photo-mail.timer
    # sudo systemctl restart import-photo-mail.service


    sudo grep -qF 'import-photos-mail.sh' /var/spool/cron/crontabs/seb || (crontab -l 2>/dev/null; echo "0 12 * * * /usr/local/bin/import-photos-mail.sh") | crontab -
    sudo grep -qF 'reboot' /var/spool/cron/crontabs/seb || (crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/import-photos-mail.sh") | crontab -



    echo "Install and configure VPN access"
    envsubst < openvpn_config/nas.ovpn > /var/tmp/nas.ovpn
    nmcli connection import type openvpn file /var/tmp/nas.ovpn
    rm -f /var/tmp/nas.ovpn
    # nmcli connection up nas
    # nmcli connection down nas


    # TODO how to set the username through CLI, and also password ??
    # https://forums.openvpn.net/viewtopic.php?t=11342

fi # GALAXY_INSTALL

echo "installating backup service"

sudo cp backups/backup.sh  /usr/local/bin/backup.sh
sudo chmod +x /usr/local/bin/backup.sh
sudo cp backups/systemd.service /etc/systemd/system/backup.service
sudo cp backups/systemd.timer /etc/systemd/system/backup.timer
sudo systemctl enable backup.service
sudo systemctl start backup.service
sudo systemctl enable backup.timer
sudo systemctl start backup.timer


echo "Installing xournal++ for pdf editing"
sudo flatpak install -y flathub com.github.xournalpp.xournalpp

# https://askubuntu.com/questions/90345/desktop-launcher-documentation
# TO find a suitable icon for your entry : find /usr/share/icons/ -name *pdf*
cat <<EOF > /var/tmp/seb.flatpak-xournalpp.desktop
[Desktop Entry]
Name=xournalpp
GenericName=Xournal++
Comment=Edit PDF file (and other) with a breeze
Exec=flatpak run com.github.xournalpp.xournalpp

## State the name of the icon that will be used to display this entry ##
Icon=gnome-mime-application-pdf
Terminal=false
Type=Application

## States the categories in which this entry should be shown menu ##
# Categories=System;Settings;GTK;HardwareSettings;
# X-Ubuntu-Gettext-Domain=usbcreator
EOF

sudo cp /var/tmp/seb.flatpak-xournalpp.desktop /usr/share/applications/

echo "Installing sushi (equivalent to apple quick look)"
sudo apt install -y gnome-sushi

echo "Install SSHD to be able to connect remotely"
sudo apt install -y openssh-server
mkdir -p /home/seb/.ssh
chmod 700 /home/seb/.ssh
echo ${UBUNTU_DESKTOP_DOUX_KEY} > /home/seb/.ssh/authorized_keys
