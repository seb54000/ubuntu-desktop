librelec config

https://wiki.libreelec.tv/how-to/mount_network_share
ls /storage/.config/system.d/storage-films.mount 

system enable / start et ensuite le mount est OK
systemctl enable storage-films.mount


[Unit]
Description=cifs mount script
Requires=network-online.service
After=network-online.service
Before=kodi.service

[Mount]
What=//local.nas.multiseb.com/home/films
Where=/storage/films
Options=username=doux,password=xoudxoud,rw,vers=2.1
Type=cifs

[Install]
WantedBy=multi-user.target





/storage/.config/autostart.sh
    if wifi is repaix then 


#!/bin/bash
iw dev wlan0 info | grep repaix
if [ $? -eq 0 ]; then
    echo "We are in Repaix, launch the VPN"
    openvpn --config /storage/.config/nas-vpn.ovpn --daemon
fi

# Will do everything (restarts) as if we were with VPN at last boot
echo "Kill existing transmission containers"
docker rm -f transmission-openvpn-core
docker rm -f transmission-openvpn-proxy

echo "wait 10 seconds"
sleep 10

echo "Restart storage mounts (films and bestphotos)"
systemctl restart storage-films.mount
systemctl restart storage-bestphotos.mount

echo "Restart docker transmission"
docker run --cap-add=NET_ADMIN -d \
    --restart=always \
    --mount type=bind,source=/storage/films/seedbox,target=/data \
    --mount type=bind,source=/storage/films/seedbox/config,target=/config \
    --mount type=bind,source=/storage/films/seedbox/ubuntu_seedbox_openvpn,target=/etc/openvpn/custom/ \
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

docker run -d \
    --restart=always \
    --link transmission-openvpn-core:transmission \
    -p 8080:8080 \
    --name transmission-openvpn-proxy \
    haugene/transmission-openvpn-proxy
    

# you can consult logs from ssh with journalctl -xe



REbuild library (could be added to autostart but maybe long)

kodi-send --host=127.0.0.1 -a "UpdateLibrary(video)"
kodi-send --host=127.0.0.1 --action="CleanLibrary(movies)"

Master lock mode on/off 

Try with custom advanced settings file
    storage/.kodi/userdata/advancedsettings.xml
    You can find any settings you like lookin g at exisitng guisettings : cat ./.kodi/userdata/guisettings.xml | grep lock

<advancedsettings>
  <setting id="masterlock.startuplock">true</setting>
</advancedsettings>


/storage/.config/master-lock.sh


Set custom service
    calling a URL on dropbox to get a value : 
        if 1,
            est-ce qu'on a true dans advancedsetttings ? 
            si OUI
                on change pour false et on reboot
            si NON on ne fait rien
        else (donc 0 ou autre chose)
            est-ce qu'on a true dans advancedsetttings ? 
            si OUI
                on fait rien
            si NON
                on met true et on reboot





https://kodi.wiki/view/HOW-TO:Remotely_update_library
    INteresting script to tests to automacially update/follow folder events
    https://forum.libreelec.tv/thread/23624-automatic-cleaning-library-on-all-players/


Hosting shared library with MySQL https://kodi.wiki/view/MySQL/Setting_up_Kodi
    don't know if possible with Librelec
        https://forum.libreelec.tv/thread/21512-using-libreelec-on-pi4-to-create-library-on-mysql-on-another-pi/
        https://forum.libreelec.tv/thread/23165-installing-mariadb-to-share-a-movie-database-in-a-network/


pour docker test 
    on ne puet pas mount sur /mnt, c'est unqiuement sur storage



TODO set a password / lock the kodi box and only activate on demand...
    https://www.maketecheasier.com/setup-parental-control-kodi/
    https://kodi.wiki/view/Settings/Interface/Master_lock
    How to do it through command line

Backup script
Change root password / set ssh only with key ??


VPN
/storage/.config/nas-vpn.creds
/storage/.config/nas-vpn.ovpn  -- based on existing (only user-auth pass file to save credneitals)
 https://forums.openvpn.net/viewtopic.php?t=11342

install kodi cli 
https://github.com/JavaWiz1/kodi-cli
Difficult to have it directly on libreelc (python pip unable to install)
But we still coudl use it remotely 

kodi-send est présent et doit pouvoir permettre déjà de la conf
https://kodi.wiki/view/List_of_built-in_functions


remote / telecommande
    https://www.amazon.fr/T%C3%A9l%C3%A9commande-T%C3%A9l%C3%A9commandes-Fonction-Ordinateur-Projecteur/dp/B07FY954Z3/ref=psdc_1455794031_t1_B01KR48RU8?th=1

intéressant, on peut aussi en ssh lancer kodi-remote qui semble permettre d'utiliser la session comme remote command
LibreELEC:~ # kodi-remote 


RCLONE sur kodi (dropbox useCase)
    https://forum.rclone.org/t/how-to-use-rclone-with-kodi-20-2-on-android-box/41277

rsync on Kodi (backup use case)
    network-tools add-on



dacberry for audio soundcard on pi400
    If you want the audio  output to appear then on Kodi settings
    dtparam=audio=on   should be activated on config.txt : https://forum.libreelec.tv/thread/23651-libreelec10-no-audio-on-3-5mm-jack/

https://wiki.libreelec.tv/configuration/config_txt
mount -o remount,rw /flash
nano /flash/config.txt
mount -o remount,ro /flash
reboot


Install addon watchdog through webUI - ability to update video library in case a new video is in the folders
    https://forum.kodi.tv/showthread.php?tid=367852


Usage of tvservice to activate / deactivate HDMI-0 or HDMI-1
    To save power (avoid heating) or to easily switch from projector to monitor with both HDMI output active (otherwise, HDMI out is only activate at bootstart if a screen is plugged, otherwise you cannot activate it after)
LibreELEC:~ # tvservice -s
tvservice is not supported when using the vc4-kms-v3d driver.
Similar features are available with standard linux tools
such as kmsprint from kms++-utils
LibreELEC:~ # kmsprint 
Connector 0 (32) HDMI-A-1 (disconnected)
  Encoder 0 (31) TMDS
Connector 1 (42) HDMI-A-2 (connected)
  Encoder 1 (41) TMDS
    Crtc 4 (107) 1920x1080@60.00 148.500 1920/88/44/148/+ 1080/4/5/36/+ 60 (60.00) P|D 
      Plane 6 (119) fb-id: 342 (crtcs: 0 1 2 3 4 5) 0,0 1920x1080 -> 0,0 1920x1080 (XR24 AR24 AB24 XB24 RG16 BG16 AR15 XR15 RG24 BG24 YU16 YV16 YU24 YV24 YU12 YV12 NV12 NV21 NV16 NV61 P030 XR30 AR30 AB30 XB30 RGB8 BGR8 XR12 AR12 XB12 AB12 BX12 BA12 RX12 RA12)
        FB 342 1920x1080 XR24

