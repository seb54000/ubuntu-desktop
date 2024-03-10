#!/bin/bash

install_vlc () {
    echo "Install VLC client"
    sudo snap install vlc
}

# install_maestral_service () {

# # TODO manage maestral install and venv creation (only if not existing)
# # Just look at TODOs md file

# # (maestral-venv) seb@galaxy-doux:~/ubuntu-desktop$ maestral config-files
# # Config name  Account                           Path                                   
# # carole       caroledropboxphotos@multiseb.com  /home/seb/.config/maestral/carole.ini  
# # seb          sebastien.claude@multiseb.com     /home/seb/.config/maestral/seb.ini   

# # https://stackoverflow.com/questions/48195340/systemd-with-multiple-execstart
#     cat <<EOF > /var/tmp/maestral@.service
#     [Unit]
#     Description=maestral service %I
#     StartLimitIntervalSec=500
#     StartLimitBurst=5

#     [Service]
#     # Type=forking
#     Type=notify
#     Restart=on-failure
#     RestartSec=5s
#     User=seb
#     # WorkingDirectory=
#     ExecStart=/home/seb/ubuntu-desktop/maestral-venv/bin/python3 -m maestral start --config-name="%i"

#     [Install]
#     WantedBy=multi-user.target
# EOF
#     sudo mv /var/tmp/maestral@.service /etc/systemd/system/
#     sudo systemctl enable maestral@seb.service
#     sudo systemctl enable maestral@carole.service
#     sudo systemctl start maestral@seb.service
#     sudo systemctl start maestral@carole.service

# }

install_chrome () {
    echo "Install Google chrome"
    [ -f /usr/bin/google-chrome ] || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo dpkg -i ./google-chrome*.deb && \
    rm ./google-chrome*.deb
}

install_ledger () {
    # https://www.chiarulli.me/Crypto/ledger-live/
    # https://download.live.ledger.com/latest/linux
    curl -o ledger-live.AppImage https://download.live.ledger.com/ledger-live-desktop-2.73.1-linux-x86_64.AppImage
    chmod +x ledger-live.AppImage
    sudo mv ledger-live.AppImage /usr/local/bin/
    wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

    wget -P ~/.local/share/icons/ https://coinzodiac.com/wp-content/uploads/2018/10/ledger-live-icon.png

    cat <<EOF > /var/tmp/seb.ledger-live.desktop
    [Desktop Entry]
    Type=Application
    Name=Ledger Live
    Comment=Ledger Live
    Icon=/home/seb/local/share/icons/ledger-live-icon.png
    Exec=/usr/local/bin/ledger-live.AppImage --no-sandbox
    Terminal=false
    Categories=crypto;wallet
EOF

    sudo mv /var/tmp/seb.ledger-live.desktop /usr/share/applications/
    # mv ledger-live.desktop ~/.local/share/applications

    # In ledge app, you will then have to reimport the accounts : with nano S plugged
    # Go to My  ledger and add account for Bitcoin and Ehtereum, it will find existing ones on the nano


}