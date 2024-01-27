Prepare films for LEonard

conserve only audio track and subtitles
https://mkvtoolnix.download/doc/mkvmerge.html
https://superuser.com/questions/77504/how-to-strip-audio-streams-from-an-mkv-file   

for file in $(ls /mnt/films/kids/The.Simpsons.S01.MULTi.HappyLee.Remaster.720p.AC3.x265-STEGNER/); do
    mkvmerge -o Downloads/${file} --audio-tracks 2 --subtitle-tracks 5 /mnt/films/kids/The.Simpsons.S01.MULTi.HappyLee.Remaster.720p.AC3.x265-STEGNER/${file} 
done


for file in /mnt/films/seedbox/completed/Stranger\ Things\ S01\ MULTi\ \[1080p\]\ BluRay\ x264-PopHD/*.mkv; do
    mkvmerge -o "/mnt/films/english_only/$(basename "${file}")" --audio-tracks 2 --subtitle-tracks 5 "${file}"
done



Convert files in /mnt/films/english_only

Piste de travail pour VCL en mode kiosk
  504  vlc /mnt/films/Django\ 2017\ 1080p\ FR\ X264\ AC3-mHDgz.mkv --fullscreen --no-keyboard-events --loop --no-osd --no-audio

  518  sudo apt install vlc vlc-bin
  519  cvlc /mnt/films/Django\ 2017\ 1080p\ FR\ X264\ AC3-mHDgz.mkv --fullscreen --no-keyboard-events --loop --no-osd --no-audio

Pist epour ubunut en mode kiosk
https://www.instructables.com/Setting-Up-Ubuntu-as-a-Kiosk-Web-Appliance/

algorithme pour le access service
    if fichier == english (ou leo)
      activate only leo account
      proxy rule (all is block)

      umount films and other stuff
        or manage rights through chmod 750 as they belong to seb
      mount english_only 
      Add a shortcut on the desktop

Comment remettre la configuration en état ensuite ?
  mount other filesystem ?
    try to chmod 750 /mnt/films to try

