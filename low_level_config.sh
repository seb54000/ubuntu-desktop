

# https://ubuntu.com/core/docs/networkmanager/configure-wifi-connections
nmcli d wifi connect multig password ${WIFI_PASSWORD}

https://superuser.com/questions/1758371/connect-to-gnome-online-accounts-with-commande-line
gnoem online accounts -- Google


Git config just (not needed for git clone)

git config --global user.name "seb54000"
git config --global user.email seb54000@gmail.com


What canoot be in script (maybe in cloudinit)
    first user creation
    git install : sudo apt install -y git
    setup the .env file