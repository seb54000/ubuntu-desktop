
echo "Begin to modify the password policy"
# # sudo sed -i '/^.*pam_pwquality.so.*/s/^/#/' /etc/pam.d/common-password 
# TODO moo ile to comment in a idempotent way
# # password      requisite                       pam_pwquality.so retry=3
# # password      [success=2 default=ignore]      pam_unix.so obscure use_authtok try_first_pass yescrypt
# password    [success=1 default=ignore]  pam_unix.so minlen=1 sha512
# # password      sufficient                      pam_sss.so use_authtok

# We will use a template
sudo cp user_mgmt/pam.config /etc/pam.d/common-password


# Creating users theo /leo
sudo useradd -m -s /bin/bash ${USERNAME_THEO}
echo "${USERNAME_THEO}:${PASSWORD_THEO}" | sudo chpasswd
sudo useradd -m -s /bin/bash ${USERNAME_LEO}
echo "${USERNAME_LEO}:${PASSWORD_LEO}" | sudo chpasswd

