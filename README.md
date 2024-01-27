# ubuntu-desktop

[[_TOC_]]

Files, scripts, and other stuff to fully manage my desktops


## OS install and first steps (until cloning this repo)

Target is to auto install in a cloud init manner the whole OS and configuration,but before reaching this goal there are still manual steps :
- Install the OS through the installer (manually creating the first user : seb)
- First login and finish the 3/4 questions process (you can do later the GNOME online accounts config if you like)
- sudo apt install -y git
- git clone https://github.com/seb54000/ubuntu-desktop.git
- get SSH public key : https://gist.githubusercontent.com/seb54000/9a112282dc69ba9e9248634deabaa0e0/raw/eeda7a6b0ca3da0a0876b8ec6dd00626012737c4/gistfile1.txt



## Pre-requisites

`source .env` that vwill contain some secrets (hold in keypaas) and needed to choose some password or thing like that



## Post-install tasks

Simply run the `post-install.sh` script
