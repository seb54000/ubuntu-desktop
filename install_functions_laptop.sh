#!/bin/bash

install_vlc () {
    echo "Install VLC client"
    sudo snap install vlc
}

install_chrome () {
    echo "Install Google chrome"
    [ -f /usr/bin/google-chrome ] || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo dpkg -i ./google-chrome*.deb && \
    rm ./google-chrome*.deb
}