#!/bin/bash

install_kids_game_timer () {
    echo "Install kids_game_timer service"
    # This will regularly look on dropbox to decide if we should stop or start Gaming host for a specific duration
    sudo cp kids_game_service/kids_game_timer.sh /usr/bin/kids_game_timer.sh
    sudo cp kids_game_service/kids_game_timer.service /etc/systemd/system/kids_game_timer.service
    sudo systemctl enable kids_game_timer
    sudo systemctl restart kids_game_timer
    sudo systemctl status kids_game_timer --no-pager
}

install_transmission () {
    #seedbox
    docker ps | grep transmission-openvpn-core &> /dev/null || \
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
    --name transmission-openvpn-core \
    haugene/transmission-openvpn

    docker ps | grep transmission-openvpn-proxy &> /dev/null || \
    docker run -d \
      --restart unless-stopped \
      --link transmission-openvpn-core:transmission \
      -p 8080:8080 \
      --name transmission-openvpn-proxy \
      haugene/transmission-openvpn-proxy
}

install_msmtp () {
    echo "mstmp with gmail config"
    sudo apt-get -y install msmtp
    envsubst < import_photos/msmtp.conf > /var/tmp/msmtp.conf.subst
    sudo mv /var/tmp/msmtp.conf.subst /etc/msmtprc
    sudo chown root:root /etc/msmtprc
    sudo chmod 600 /etc/msmtprc
}

install_import_photos () {
    echo "Installing import photos scripts"
    sudo apt-get -y install fdupes exiftool

    sudo cp import_photos/import-photos.sh /usr/local/bin/import-photos.sh
    sudo chmod +x /usr/local/bin/import-photos.sh
    sudo cp import_photos/import-photos-mail.sh /usr/local/bin/import-photos-mail.sh
    sudo chmod +x /usr/local/bin/import-photos-mail.sh
    sudo cp import_photos/import-photos-rating-dispatch.sh /usr/local/bin/import-photos-rating-dispatch.sh
    sudo chmod +x /usr/local/bin/import-photos-rating-dispatch.sh

    sudo cp import_photos/systemd.service /etc/systemd/system/import-photo-mail.service
    sudo cp import_photos/systemd.timer /etc/systemd/system/import-photo-mail.timer
    sudo systemctl enable import-photo-mail.service
    sudo systemctl start import-photo-mail.service
    sudo systemctl enable import-photo-mail.timer
    sudo systemctl start import-photo-mail.timer

    # sudo grep -qF 'import-photos-mail.sh' /var/spool/cron/crontabs/seb || (crontab -l 2>/dev/null; echo "0 12 * * * /usr/local/bin/import-photos-mail.sh") | crontab -
    # sudo grep -qF 'reboot' /var/spool/cron/crontabs/seb || (crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/import-photos-mail.sh") | crontab -
}

install_xrdp () {
    echo "install XRDP"
    sudo apt install xrdp -y
    sudo adduser xrdp ssl-cert
    sudo systemctl enable xrdp
    # sudo usermod -a -G ssl-cert xrdp
    sudo systemctl restart xrdp
}

install_kodi () {
    echo "Manage kodi install"
    if ! command -v kodi &> /dev/null; then sudo apt install -y kodi ; fi
    # TODO for each user 
    mkdir -p /home/seb/.kodi
    # fstab line with uid / gid
    # grep -qF '/home/seb/.kodi' /etc/fstab || echo "//local.nas.multiseb.com/home/films/kodi_datas /home/seb/.kodi cifs credentials=/etc/.doux.smb.credentials,iocharset=utf8,uid=$(id -u seb),gid=$(id -g seb) 0 0" | sudo tee -a /etc/fstab > /dev/null
    # sudo mount -a
    # https://kodi.wiki/view/Kodi_data_folder
}

