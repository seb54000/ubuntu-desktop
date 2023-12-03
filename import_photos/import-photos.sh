#!/bin/bash
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin

#.  Il faut copier les photos qu’on veut classer à la racine de l’arborescence des photos classées
#	(on sépare les vidéos et les photos à ce moment là puisqu’il y aura deux arborescences - à voir si on fait évoluer par la suite)
#	cd répertoire Dropbox ou autre
#
#. En cas d’erreur de type
#	Warning: No writable tags set from ./20170217-155936-SEB-IMG.jpg
#	http://u88.n24.queensu.ca/exiftool/forum/index.php?topic=5912.0
#		Il faut écrire soit même le tag createdate
#			exiftool "-CreateDate<FileModifyDate" "-timecreated<FileModifyDate" "-datecreated<FileModifyDate" -ext "jpg" .
#		Pour savoir quel tag utiliser, on peut lister tous les tags positionnés sur une image
#			exiftool -time:all -s *
#
#. En cas d'erreur de type Error:
##  File format error - ./._20170902-175811-SEB-VID.MOV
# On a un file type AppleDouble format    https://en.wikipedia.org/wiki/AppleSingle_and_AppleDouble_formats
# MacBook-Pro-de-Sebastien:Propres doux$ file ._20170902-175811-CAR-VID.MOV
# ._20170902-175811-CAR-VID.MOV: AppleDouble encoded Macintosh file
# Attention il y a aussi un fichier sans le ._ qui a le bon format !!
# MacBook-Pro-de-Sebastien:Propres doux$ file 20170902-175811-CAR-VID.MOV
# 20170902-175811-CAR-VID.MOV: ISO Media, Apple QuickTime movie, Apple QuickTime (.MOV/QT)
#   il faut faire un dot_clean -m sur le répertoire
# dot_clean -m .


#  https://ole.michelsen.dk/blog/schedule-jobs-with-crontab-on-mac-osx.html
#  /Users/doux/Documents/Dev-tools-utils-projects/scripts/import-photos.sh 2>&1 | mail -s "import photos" "seb54000@gmail.com"

# Launch le lance tous les jours à 12h : com.multiseb.photoimporter
# /Users/doux/Documents/Dev-tools-utils-projects/scripts/import-photos-mail.sh
# /Users/doux/Documents/Dev-tools-utils-projects/scripts/import-photos-mail.output.log
# /Users/doux/Documents/Dev-tools-utils-projects/scripts/import-photos-mail.error.log



#######
# Nas automount réferences
#  https://gist.github.com/rudelm/7bcc905ab748ab9879ea
#  http://blog.grapii.com/2015/06/keep-network-drives-mounted-on-mac-os-x-using-autofs/
#  https://forum.synology.com/enu/viewtopic.php?t=8416  // AppleScript 
#  sudo vi /etc/auto_master ## See AutoFS

## Obligatoires dans /etc/auto_master et qui je pense avait sauté lors d'une update MacOS
# /mnt/nas                auto_homes_syno
# Il n'y a besoin d'aucune autre option mais c'est bien cela qui va permettre de charger le fichier auto_home_syno qui a tous les détails
# Attention aussi en obligatoire :
# sudo chmod 644 /etc/auto_homes_syno     # s'il n'y a pas ces droits, ça ne marche pas...
# https://gist.github.com/L422Y/8697518
# sudo automount -vc pour prise en compte des changements

# Check dropboxes are running (if not start them)
ps -efw | grep -e \/seb\/.dropbox-dist | grep -v grep > /tmp/droptest
grep -e dropbox-dist /tmp/droptest
if [ "$?" -ne "0" ]; then
	echo "Dropbox Seb is not running, start it"
	set -e
	/usr/bin/dropbox start > /dev/null
	set +e
	sleep 15
	rm -f /tmp/droptest
fi

ps -efw | grep -e dropbox-carole | grep -v grep > /tmp/droptest
grep -e dropbox-carole /tmp/droptest
if [ "$?" -ne "0" ]; then
	echo "Actual HOME = $HOME"
	ACTUAL_HOME=$HOME
	echo "Dropbox Carole is not running, start it"
	set -e
	export HOME="/home/seb/.dropbox-carole" && /usr/bin/dropbox start > /dev/null
	set +e
	sleep 15
	export HOME=$ACTUAL_HOME
	echo "Restore actual HOME : $HOME"
	rm -f /tmp/droptest
fi


WARNING_ON_EXEC=0

# Pour les espaces dans les variables, c'est soit TEST="Mon espace" soit TEST=Mon\ espace
NAS_MOUNT_POINT="/mnt/doux"
#SOURCE DIRS
PHOTOS_VIDEOS_SOURCE_DIR_SEB="/home/seb/Dropbox/Chargements appareil photo/"
PHOTOS_VIDEOS_SOURCE_DIR_CAR="/home/seb/.dropbox-carole/Dropbox/Chargements appareil photo/"
PHOTOS_VIDEOS_SOURCE_TEMP_DIR_SEB="${PHOTOS_VIDEOS_SOURCE_DIR_SEB}rsynctemp/"
PHOTOS_VIDEOS_SOURCE_TEMP_DIR_CAR="${PHOTOS_VIDEOS_SOURCE_DIR_CAR}rsynctemp/"

#WORK DIRS
PHOTOS_WORK_DIR_SEB="/home/seb/Documents/Photos/tempSEB/"
PHOTOS_WORK_DIR_CAR="/home/seb/Documents/Photos/tempCAR/"
VIDEOS_WORK_DIR_SEB="${NAS_MOUNT_POINT}/Videos librairie/tempSEB/"
VIDEOS_WORK_DIR_CAR="${NAS_MOUNT_POINT}/Videos librairie/tempCAR/"

#TARGET DIRS (Libraries)
#GLOBAL_PHOTOS_LIBRARY="/Volumes/Macintosh HD/Users/Shared/partage/Photos/Photos selection librairie/"
GLOBAL_PHOTOS_LIBRARY="/mnt/triphotos/"
GLOBAL_VIDEOS_LIBRARY="${NAS_MOUNT_POINT}/Videos librairie/Propres/"

# Keep for comments but unused as we now skip (comment) the specific backup section for CAR
#BACKUP_PHOTOS_TARGET_DIR_CAR="${NAS_MOUNT_POINT}/Backup Carole photos/"
#BACKUP_VIDEOS_TARGET_DIR_CAR="${NAS_MOUNT_POINT}/Backup Carole videos/"


## ajouter un test que les répertoires existent et si ce n'est pas le cas sortir en exit1 ??

#mkdir -p $SEB_PHOTOS_WORK_DIR
#mkdir -p $CAROLE_PHOTOS_WORK_DIR
#mkdir -p $TOSHIBA_VIDEO_SEB_WORKDIR
#mkdir -p $TOSHIBA_VIDEO_CAROLE_WORKDIR



for USER in CAR SEB ; do
	echo "----------------------------------------------------"
	echo "Main loop for user, currently adressing User : $USER"
	PHOTOS_VIDEOS_SOURCE_DIR=PHOTOS_VIDEOS_SOURCE_DIR_${USER}
	PHOTOS_VIDEOS_SOURCE_DIR=${!PHOTOS_VIDEOS_SOURCE_DIR}
	echo "PHOTOS_VIDEOS_SOURCE_DIR for user $USER : ${PHOTOS_VIDEOS_SOURCE_DIR}"
	echo ""

 
	PHOTOS_VIDEOS_SOURCE_DIR=PHOTOS_VIDEOS_SOURCE_DIR_${USER}
	PHOTOS_VIDEOS_SOURCE_DIR="${!PHOTOS_VIDEOS_SOURCE_DIR}"
	PHOTOS_VIDEOS_SOURCE_TEMP_DIR=PHOTOS_VIDEOS_SOURCE_TEMP_DIR_${USER}
	PHOTOS_VIDEOS_SOURCE_TEMP_DIR="${!PHOTOS_VIDEOS_SOURCE_TEMP_DIR}"
	PHOTOS_WORK_DIR=PHOTOS_WORK_DIR_${USER}
	PHOTOS_WORK_DIR="${!PHOTOS_WORK_DIR}"
	VIDEOS_WORK_DIR=VIDEOS_WORK_DIR_${USER}
	VIDEOS_WORK_DIR="${!VIDEOS_WORK_DIR}"

	# on recherche tous les fichiers du répertoire source et on les copie sauf le plus récent (potentiellement encore en cours d'écriture dans le répertoire temporaire de la dropbox pour sécuriser le rsync)
	# tail -n2 permet d'enlever la première ligne du résultat de ls, -tu permet de trier suivant la date d'accès, xargs "FILE" avec les doubles quotes permet de gérer les espaces dans les résultats de ls
	#https://www.unixtutorial.org/2008/04/atime-ctime-mtime-in-unix-filesystems/
	mkdir -p "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}"
	cd "${PHOTOS_VIDEOS_SOURCE_DIR}"
	ls -tu "${PHOTOS_VIDEOS_SOURCE_DIR}" | tail -n+2 | xargs -I FILE mv "FILE" "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" 
	echo "---- Move all files (except last one) from ${PHOTOS_VIDEOS_SOURCE_DIR} to ${PHOTOS_VIDEOS_SOURCE_TEMP_DIR} for User : $USER to avoid uncomplete write ----"
	echo ""

	# if [ "$USER" == "CAR" ]; then
	# 	cd "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}"
	# 	echo "Backup supplémentaires pour les fichiers du user : $USER only"
	# 	echo ""
	# 	# Backup des photos : BACKUP_PHOTOS_TARGET_DIR_CAR
	# 	echo "---- //Specific backup// Move with Rsync PHOTOS files from ${PHOTOS_VIDEOS_SOURCE_TEMP_DIR} to ${BACKUP_PHOTOS_TARGET_DIR_CAR} for User : $USER ----"
	# 	echo ""
	# 	rsync --include='*.jpg' --include='*.JPG' --include='*.png' --include='*.PNG' --exclude='*' -avh "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" "${BACKUP_PHOTOS_TARGET_DIR_CAR}" 2>&1
	# 	# Backup des videos : BACKUP_VIDEOS_TARGET_DIR_CAR
	# 	echo "---- //Specific backup// Move with Rsync VIDEOS files from ${PHOTOS_VIDEOS_SOURCE_TEMP_DIR} to ${BACKUP_VIDEOS_TARGET_DIR_CAR} for User : $USER ----"
	# 	echo ""
	# 	rsync --include='*.mov' --include='*.MOV' --include='*.mp4' --include='*.MP4' --exclude='*' -avh "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" "${BACKUP_VIDEOS_TARGET_DIR_CAR}" 2>&1
	# fi

	# On copie via rsync (déplace : --remove-source-files) les fichiers (photos et videos) dont on est maintenant sûr que personne n'écrit dessus dans le répertoire de travail temporaire en dehors de la dropbox
	cd "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" 
	echo "---- Move with Rsync PHOTOS files from ${PHOTOS_VIDEOS_SOURCE_TEMP_DIR} to ${PHOTOS_WORK_DIR} for User : $USER ----"
	echo ""
	rsync --remove-source-files --include='*.jpg' --include='*.JPG' --include='*.png' --include='*.PNG' --exclude='*' -avh "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" "${PHOTOS_WORK_DIR}" 2>&1
	echo "---- Move with Rsync VIDEOS files from ${PHOTOS_VIDEOS_SOURCE_TEMP_DIR} to ${VIDEOS_WORK_DIR} for User : $USER ----"
	echo ""
	rsync --remove-source-files --include='*.mov' --include='*.MOV' --include='*.mp4' --include='*.MP4' --exclude='*' -avh "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" "${VIDEOS_WORK_DIR}" 2>&1

	cd ..
	rmdir "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" 
	if [ "$?" -ne "0" ]; then
		echo " WARNING : Des fichiers non pris en charge sont encore dans le répertoire ${PHOTOS_VIDEOS_SOURCE_TEMP_DIR} qui ne peut être supprimé, liste des fichiers ci-dessous"
		echo " WARNING : Il peut s'agir parfois simplement de l'extension, on prend uniquement jpg|JPG|png|PNG|mov|MOV|mp'|MP4 (pas jpeg par exemple)"
		echo ""
		ls "${PHOTOS_VIDEOS_SOURCE_TEMP_DIR}" 
		WARNING_ON_EXEC=1
	fi

	# Renommage des fichiers photos via exiftool
	cd "$PHOTOS_WORK_DIR"
	echo "---- écriture de la date de création dans les données exif pour éviter les erreurs no writable tags set (uniquement pour les fichiers n'ayant pas encore de date) ----"
	echo ""
	exiftool -p '$filename|$createdate' -q -f . | awk -F "|" '{ if ($2 == "-") print $1}' | while IFS='' read -r filetoprocess || [[ -n "$filetoprocess" ]]; do exiftool "-CreateDate<FileModifyDate" "-timecreated<FileModifyDate" "-datecreated<FileModifyDate" "$filetoprocess"; done

	echo "---- Rename des JPG et PNG du user : $USER via exiftool dans le répertoire $PHOTOS_WORK_DIR ----" 
	echo ""
	exiftool -d %Y%m%d-%H%M%S-${USER}-IMG%%c.%%e "-filename<createdate" -ext "jpg" -ext "png" .

	echo "---- Vérification qu'il n'y a pas de fichiers duplicas dans $PHOTOS_WORK_DIR pour user : $USER avant copie dans $GLOBAL_PHOTOS_LIBRARY ----" 
	echo ""
	fdupes -dN .

	echo "---- Déplacement des fichiers photos (jpg , png) que l'on a renommés dans le répertoire $GLOBAL_PHOTOS_LIBRARY ----"
	echo ""
	rsync --remove-source-files --include='*.jpg' --include='*.JPG' --include='*.png' --include='*.PNG' --exclude='*' -avh "${PHOTOS_WORK_DIR}" "${GLOBAL_PHOTOS_LIBRARY}" 2>&1


	# Renommage des fichiers vidéos via exiftool
	cd "$VIDEOS_WORK_DIR"
	# pour éviter une possible erreur : File format error - ./._20170902-175811-SEB-VID.MOV
	# dot_clean -m .
	# Remove this on ubuntu as ._ files are on MacOS only

	echo "---- Rename des MOV et MP4 du user : $USER via exiftool dans le répertoire $VIDEOS_WORK_DIR ----" 
	echo ""
	exiftool -d %Y%m%d-%H%M%S-${USER}-VID%%c.%%e "-filename<createdate" -ext "mov" -ext "mp4" .

	echo "---- Vérification qu'il n'y a pas de fichiers duplicas dans $VIDEOS_WORK_DIR pour user : $USER avant copie dans $GLOBAL_VIDEOS_LIBRARY ----" 
	echo ""
	fdupes -dN .

	echo "---- Déplacement des fichiers vidéos (mov, mp4) que l'on a renommés dans le répertoire $GLOBAL_VIDEOS_LIBRARY ----"
	echo ""
	rsync --remove-source-files --include='*.mov' --include='*.MOV' --include='*.mp4' --include='*.MP4' --exclude='*' -avh "${VIDEOS_WORK_DIR}" "${GLOBAL_VIDEOS_LIBRARY}" 2>&1

done
# Fin de la boucle for

echo "------ Réorganisation globale des répertoire photos et videos par répertoires date YYY-MM via exiftool -----"
echo ""
echo " -- Photos in $GLOBAL_PHOTOS_LIBRARY --"
cd "$GLOBAL_PHOTOS_LIBRARY"
exiftool -d %Y/%m "-Directory<CreateDate" -ext "jpg" -ext "png" .
echo " -- Videos in $GLOBAL_VIDEOS_LIBRARY --"
cd "$GLOBAL_VIDEOS_LIBRARY"
exiftool -d %Y/%m "-Directory<CreateDate" -ext "mp4" -ext "mov" .


if [ "$WARNING_ON_EXEC" -ne "0" ]; then
	echo "WARNING non bloquant à l'exécution, consulter la log et chercher WARNING"
	exit 2
fi





