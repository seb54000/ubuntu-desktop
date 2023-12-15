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


source .env
source $(dirname $0)/install_functions_common.sh
source $(dirname $0)/install_functions_laptop.sh
source $(dirname $0)/install_functions_pibox.sh


### Common config ###
configure_sudo
configure_nas_shares
install_docker
install_keepass
install_backup


### End Common config ###



### Galaxy config - main laptop ###
if [ ${GALAXY_INSTALL} == "1" ]; then
    /usr/bin/bash $(dirname $0)/user_mgmt/create_user.sh
    install_chrome
    install_vlc

    # Should go to Raspberry but dropbox not supported for the moment
    install_msmtp
    install_import_photos
    install_kids_game_timer

fi

### Kids latpop config ###



### PI400 seedbox / mediacenter on Raspberry ###
if [ ${PI400_INSTALL} == "1" ]; then    
    install_transmission
    install_kodi

    install_xrdp
fi


### Gaming Host ??? ####


exit 0




echo "install Vscode"
sudo snap install code --classic
    # TODO manage extensions
        # Shell outline
        # python
        # remote ssh



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


# TODO - only once for the squid.conf.orig (if already exists don't do it again)
# sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
echo -e '.youtube.com\n.tiktok.com\n.scratch.mit.edu\n.mess.eu.org\n.buildnowgg.com\n.miniroyale.io' | sudo tee /etc/squid/bad_urls.acl > /dev/null
sudo cp squid/squid.conf /etc/squid/squid.conf
sudo cp squid/error.html /etc/squid/error.html
sudo cp squid/squid.custom.conf /etc/squid/conf.d/squid.custom.conf
sudo systemctl reload squid
# TODO squidGuard.log may not exist at the begining maybe let-s create it if not exists
# sudo chmod 666 /var/log/squid/squidGuard.log

# https_proxy=http://localhost:3128 curl https://www.google.fr
# # cat /var/log/squidguard/suidgard.log
# https_proxy=http://localhost:3128 curl -kv https://scratch.mit.edu
# https_proxy=http://localhost:3128 curl -kv https://xhamster.com
# echo “https://xhamster.com / - - GET” | sudo squidGuard -c /etc/squidguard/squidGuard.conf -d

# https://michauko.org/blog/squidguard-filtre-durl-et-listes-a-jour-le-plus-dur-313/




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




if [ ${GALAXY_INSTALL} == "1" ]; then

    echo "install Gthumb and Geeqie"
    sudo apt install -y gthumb geeqie exiftool

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
    sudo apt install -y nautilus-dropbox
        # The start of the second dropbox is done thrugh this command (laucnhed on a new terminal for frst configuration)
            # export HOME="/home/seb/.dropbox-carole" && /usr/bin/dropbox start -i
        # The import-photos.sh script will check that everythgin is started and restart

    echo "INstalling WhatsApp" 
    # https://github.com/eneshecan/whatsapp-for-linux
    sudo snap install whatsapp-for-linux

    echo "Define favorites for seb user"

    export APP_LIST="['org.gnome.Nautilus.desktop', 'libreoffice-writer.desktop', 'libreoffice-impress.desktop', 'snap-store_ubuntu-software.desktop', 'google-chrome.desktop', 'code_code.desktop', 'org.remmina.Remmina.desktop', 'seb.gnome-network-displays.desktop', 'org.gnome.gThumb.desktop']"
    gsettings set org.gnome.shell favorite-apps "${APP_LIST}"


    sudo snap install gnome-contacts
    # TODO manage synchronisation ??

    sudo snap install audacity
    sudo snap connect audacity:alsa

    sudo snap install teams-for-linux



    echo "Install and configure VPN access"
    envsubst < openvpn_config/nas.ovpn > /var/tmp/nas.ovpn
    nmcli connection import type openvpn file /var/tmp/nas.ovpn
    rm -f /var/tmp/nas.ovpn
    # nmcli connection up nas
    # nmcli connection down nas


    # TODO how to set the username through CLI, and also password ??
    # https://forums.openvpn.net/viewtopic.php?t=11342

fi # GALAXY_INSTALL


echo "INstalling python"
sudo apt install -y python-pip python3.10-venv
# TODO create as user seb a venv in $HOME/kodi-venv

echo "Install tools to manage mkv files"
sudo apt install -y mkvtoolnix


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


echo "Add Nautilus bookmarks / shortcuts"

grep -qF 'Desktop_shared' /home/seb/.config/gtk-3.0/bookmarks || echo "file:///mnt/doux/Desktop_shared Desktop_shared" >> /home/seb/.config/gtk-3.0/bookmarks
grep -qF 'Documents_shared' /home/seb/.config/gtk-3.0/bookmarks || echo "file:///mnt/doux/Documents_shared Documents_shared" >> /home/seb/.config/gtk-3.0/bookmarks
grep -qF 'Downloads_shared' /home/seb/.config/gtk-3.0/bookmarks || echo "file:///mnt/doux/Downloads_shared Downloads_shared" >> /home/seb/.config/gtk-3.0/bookmarks
grep -qF 'Paie' /home/seb/.config/gtk-3.0/bookmarks || echo "file:///mnt/doux/Documents_shared/Papiers%20administratif%20archives/Employeur/BDF/Paie Paie" >> /home/seb/.config/gtk-3.0/bookmarks
grep -qF 'Quittances' /home/seb/.config/gtk-3.0/bookmarks || echo "file:///mnt/doux/Documents_shared/Papiers%20administratif%20archives/Appartement/VALOIS/Quittances Quittances" >> /home/seb/.config/gtk-3.0/bookmarks

echo "Installing Gimp for cards and more"
sudo apt install -y gimp

echo "set recursive search in Nautilus to be bale to easily search within NAS and remote dirs"
# https://askubuntu.com/questions/852940/how-can-i-make-files-search-recursively-within-a-network-share
gsettings set org.gnome.nautilus.preferences recursive-search 'always'

echo "Install pdfjam very handy to manipulate pdf (join them, etc..)"
sudo apt install -y texlive-extra-utils


echo "Associate mime video fileTYpe association with VLC"
# - https://help.gnome.org/admin/system-admin-guide/stable/mime-types-application-user.html.en
sudo sed -i s/org.gnome.Totem.desktop/vlc_vlc.desktop/g /usr/share/applications/gnome-mimeapps.list

echo "Associate mime pdf fileTYpe association with xournalpp"
sudo sed -i s/org.gnome.Totem.desktop/seb.flatpak-xournalpp.desktop/g /usr/share/applications/gnome-mimeapps.list

# seb.flatpak-xournalpp.desktop 