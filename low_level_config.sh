

# https://ubuntu.com/core/docs/networkmanager/configure-wifi-connections
nmcli d wifi connect multig password ${WIFI_PASSWORD}

# https://superuser.com/questions/1758371/connect-to-gnome-online-accounts-with-commande-line
# gnoem online accounts -- Google


# Git config just (not needed for git clone)

git config --global user.name "seb54000"
git config --global user.email seb54000@gmail.com

# set screen resolution in GNOME ?
# Desktop 
# xrandr --output 'HDMI-0' --mode '1920x1080_60.00'
# https://www.baeldung.com/linux/adjust-screen-resolution

# What canoot be in script (maybe in cloudinit)
#     first user creation
#     git install : sudo apt install -y git
#     setup the .env file

echo "Create new user and modify password policy"

# # sudo sed -i '/^.*pam_pwquality.so.*/s/^/#/' /etc/pam.d/common-password 
# TODO moo ile to comment in a idempotent way
# # password      requisite                       pam_pwquality.so retry=3
# # password      [success=2 default=ignore]      pam_unix.so obscure use_authtok try_first_pass yescrypt
# password    [success=1 default=ignore]  pam_unix.so minlen=1 sha512
# # password      sufficient                      pam_sss.so use_authtok

sudo useradd -m -s /bin/bash ${USERNAME_THEO}
echo "${USERNAME_THEO}:${PASSWORD_THEO}" | sudo chpasswd
sudo useradd -m -s /bin/bash ${USERNAME_LEO}
echo "${USERNAME_THEO}:${PASSWORD_LEO}" | sudo chpasswd




# TODO set default soundCard output for DEKSTOP
# https://askubuntu.com/questions/1038490/how-do-you-set-a-default-audio-output-device-in-ubuntu
