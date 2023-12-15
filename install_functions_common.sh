#!/bin/bash

### Common config ###
#####################
configure_sudo () {
    echo "Manage sudo rights for seb user"
    [ -f /etc/sudoers.d/seb ] || echo "seb ALL=(ALL) NOPASSWD:ALL" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/seb')
}

install_docker () {
    if ! command -v docker &> /dev/null
    then
        sudo snap install docker
        sudo groupadd -f docker
        # sudo usermod -aG docker seb
        sudo gpasswd -a seb docker 
        sudo chmod 666 /var/run/docker.sock
    fi
}

install_keepass () {
    if ! command -v keepassxc &> /dev/null
    then
        echo "Install Keepass and launch with a shared DB on NAS"
        sudo apt install -y keepassxc
        # TODO add keepass to favorites in GNOME
        # TODO need an rsync with google drive

        # Keepass is ubuntu_keepass in /mnt/doux
        # https://www.padok.fr/en/blog/ssh-keys-keepassxc
    fi
}

install_backup () {
    if  [ ! -f /usr/local/bin/backup.sh ]; then
        echo "installing backup service"
        sudo cp backups/backup.sh /usr/local/bin/backup.sh
        sudo chmod +x /usr/local/bin/backup.sh
        sudo cp backups/systemd.service /etc/systemd/system/backup.service
        sudo cp backups/systemd.timer /etc/systemd/system/backup.timer
        sudo systemctl enable backup.service
        sudo systemctl start backup.service
        sudo systemctl enable backup.timer
        sudo systemctl start backup.timer
    fi
}

configure_nas_shares () {
    if ! command -v mount.cifs &> /dev/null; then 
        sudo apt-get install -y cifs-utils
    fi
    # Create a smb credentials file with limited access
    if [ ! -f /etc/.doux.smb.credentials ] ; then
        cat <<EOF > /var/tmp/.doux.smb.credentials
username=${DOUX_SMB_USERNAME}
password=${DOUX_SMB_PASSWORD}
EOF
        sudo mv /var/tmp/.doux.smb.credentials /etc/.doux.smb.credentials
        sudo chmod 600 /etc/.doux.smb.credentials
        sudo chown root:root /etc/.doux.smb.credentials
    fi

    if [ ! -f /etc/.famille.smb.credentials ] ; then
        cat <<EOF > /var/tmp/.famille.smb.credentials
username=${FAMILLE_SMB_USERNAME}
password=${FAMILLE_SMB_PASSWORD}
EOF
        sudo mv /var/tmp/.famille.smb.credentials /etc/.famille.smb.credentials
        sudo chmod 600 /etc/.famille.smb.credentials
        sudo chown root:root /etc/.famille.smb.credentials
    fi

    if [ ! -f /etc/.douce.smb.credentials ] ; then
        cat <<EOF > /var/tmp/.douce.smb.credentials
username=${DOUCE_SMB_USERNAME}
password=${DOUCE_SMB_PASSWORD}
EOF
        sudo mv /var/tmp/.douce.smb.credentials /etc/.douce.smb.credentials
        sudo chmod 600 /etc/.douce.smb.credentials
        sudo chown root:root /etc/.douce.smb.credentials
    fi

    if [ ! -f /etc/.bestphotos.smb.credentials ] ; then
        cat <<EOF > /var/tmp/.bestphotos.smb.credentials
username=${BEST_SMB_USERNAME}
password=${BEST_SMB_PASSWORD}
EOF
        sudo mv /var/tmp/.bestphotos.smb.credentials /etc/.bestphotos.smb.credentials
        sudo chmod 600 /etc/.bestphotos.smb.credentials
        sudo chown root:root /etc/.bestphotos.smb.credentials
    fi

    sudo mkdir -p /mnt/films
    sudo chown seb:seb /mnt/films
    sudo chmod 750 /mnt/films
    grep -qF '/mnt/films' /etc/fstab || echo "//local.nas.multiseb.com/home/films /mnt/films cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/english_only
    sudo chown seb:seb /mnt/english_only
    sudo chmod 755 /mnt/english_only
    grep -qF '/mnt/english_only' /etc/fstab || echo "//local.nas.multiseb.com/home/films/english_only /mnt/english_only cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0755 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/nas/doux
    sudo chown seb:seb /mnt/doux
    sudo chmod 750 /mnt/doux
    grep -qF '/mnt/nas/doux' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/doux cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/nas/douce
    sudo chown seb:seb /mnt/nas/douce
    sudo chmod 750 /mnt/nas/douce
    grep -qF '/mnt/nas/douce' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/douce cifs credentials=/etc/.douce.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/nas/bestphotos
    sudo chown seb:seb /mnt/nas/bestphotos
    sudo chmod 750 /mnt/nas/bestphotos
    grep -qF '/mnt/nas/bestphotos' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/bestphotos cifs credentials=/etc/.bestphotos.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/nas/famille
    sudo chown seb:seb /mnt/nas/famille
    sudo chmod 750 /mnt/nas/famille
    grep -qF '/mnt/nas/famille' /etc/fstab || echo "//local.nas.multiseb.com/home /mnt/nas/famille cifs credentials=/etc/.famille.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    # sudo mkdir -p /mnt/theo_home_dir
    sudo mkdir -p /home/theo/network_share
    sudo chown theo:theo /home/theo/network_share
    sudo chmod 750 /home/theo/network_share
    grep -qF 'theo_home_dir' /etc/fstab || echo "//local.nas.multiseb.com/home/theo_home_dir /home/theo/network_share cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u theo),gid=$(id -g theo),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    # sudo mkdir -p /mnt/leo_home_dir
    # grep -qF 'leo_home_dir' /etc/fstab || echo "//local.nas.multiseb.com/home/leo_home_dir /home/leo cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u leo),gid=$(id -g leo),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/triphotos
    sudo chown seb:seb /mnt/triphotos
    sudo chmod 750 /mnt/triphotos
    grep -qF '/mnt/triphotos' /etc/fstab || echo "//local.nas.multiseb.com/home/Drive/Moments /mnt/triphotos cifs credentials=/etc/.famille.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    sudo mkdir -p /mnt/backup
    sudo chown seb:seb /mnt/backup
    sudo chmod 750 /mnt/backup
    grep -qF '/mnt/backup' /etc/fstab || echo "//local.nas.multiseb.com/home/ubuntu_backups /mnt/backup cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb),dir_mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null

    sudo mount -a
}
