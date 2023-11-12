# ubuntu-desktop

[[TOC]]

Files, scripts, and other stuff to fully manage my desktops


## OS install and first steps (until cloning this repo)

Target is to auto install in a cloud init manner the whole OS and configuration,but before reaching this goal there are still manual steps :
- Install the OS through the installer (manually creating the first user : seb)
- First login and finish the 3/4 questions process (you can do later the GNOME online accounts config if you like)
- sudo apt install -y git
- git clone https://github.com/seb54000/ubuntu-desktop.git



## Pre-requisites

`source .env` that vwill contain some secrets (hold in keypaas) and needed to choose some password or thing like that



## Post-install tasks

Simply run the `post-install.sh` script