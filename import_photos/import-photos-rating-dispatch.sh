#!/bin/bash


#set -e   # We prefer the script to stop as soon as one command fail

# Source dir for photos
FAMILLE_PHOTOS_LIBRARY="/mnt/nas/famille/Drive/Moments/"
# Target dir for photos with 4/5 *
BESTPHOTOS_DIR="/mnt/nas/bestphotos/Drive/Moments/"
# Target dir for photos with 2 * (douce)
CAR_MOMENTS_DIR="/mnt/nas/douce/Drive/Moments/"
# Target dir for photos with 1 * (doux)
SEB_MOMENTS_DIR="/mnt/nas/doux/Drive/Moments/"


#TODO, decide so search for files only in current year directory
if [ -z "$1" ]
  then
    echo "Using current year YEAR_TO_SEARCH : $(date +%Y)"
    YEAR_TO_SEARCH="$(date +%Y)"
  else
    echo "Using year provided as parameter YEAR_TO_SEARCH : $1"
    YEAR_TO_SEARCH="$1"
fi


echo "Find photos with 1 *, copy them in a temp dir then rsync to target DIR"
echo "Treating 1 * files (SEB photos - target dir ${SEB_MOMENTS_DIR})"
mkdir -p "${FAMILLE_PHOTOS_LIBRARY}/temp"
echo "listing files to move $(date)"
exiftool -r -if '$XMP:rating eq 1' -p '$directory/$FileName' -T "${FAMILLE_PHOTOS_LIBRARY}/${YEAR_TO_SEARCH}"
echo "moving files to temp $(date)"
exiftool -r -if '$XMP:rating eq 1' -p '$directory/$FileName' -T "${FAMILLE_PHOTOS_LIBRARY}/${YEAR_TO_SEARCH}" | xargs -I FILE mv "FILE" "${FAMILLE_PHOTOS_LIBRARY}/temp" 
echo "rsync files to target dir $(date)"
rsync --remove-source-files -avh "${FAMILLE_PHOTOS_LIBRARY}/temp/" "${SEB_MOMENTS_DIR}"
echo "Then, organize copied files by date as usual $(date)"
cd ${SEB_MOMENTS_DIR}
exiftool -d %Y/%m "-Directory<CreateDate" -ext "jpg" -ext "png" .
cd -
rmdir "${FAMILLE_PHOTOS_LIBRARY}/temp"
if [ "$?" -ne "0" ]; then
	echo " WARNING : unable to remove ${FAMILLE_PHOTOS_LIBRARY}/temp , please investigate"
	exit 1
fi

echo "Find photos with 2 *, copy them in a temp dir the rsync to target DIR"
echo "Treating 2 * files (CAROLE photos - target dir ${CAR_MOMENTS_DIR})"
mkdir -p "${FAMILLE_PHOTOS_LIBRARY}/temp"
echo "listing files to move $(date)"
exiftool -r -if '$XMP:rating eq 2' -p '$directory/$FileName' -T "${FAMILLE_PHOTOS_LIBRARY}/${YEAR_TO_SEARCH}"
echo "moving files to temp $(date)"
exiftool -r -if '$XMP:rating eq 2' -p '$directory/$FileName' -T "${FAMILLE_PHOTOS_LIBRARY}/${YEAR_TO_SEARCH}" | xargs -I FILE mv "FILE" "${FAMILLE_PHOTOS_LIBRARY}/temp" 
echo "rsync files to target dir $(date)"
rsync --remove-source-files -avh "${FAMILLE_PHOTOS_LIBRARY}/temp/" "${CAR_MOMENTS_DIR}"
echo "Then, organize copied files by date as usual $(date)"
cd ${CAR_MOMENTS_DIR}
exiftool -d %Y/%m "-Directory<CreateDate" -ext "jpg" -ext "png" .
cd -
rmdir "${FAMILLE_PHOTOS_LIBRARY}/temp"
if [ "$?" -ne "0" ]; then
	echo " WARNING : unable to remove ${FAMILLE_PHOTOS_LIBRARY}/temp , please investigate"  
	exit 1
fi

echo "Find photos with 4 and 5 *, rsync them to target DIR"
echo "Get list of files with 4* $(date)"
FOUR_STARS_LIST=`exiftool -r -if '$XMP:rating eq 4' -p '$directory/$FileName' -T "${FAMILLE_PHOTOS_LIBRARY}${YEAR_TO_SEARCH}"`
echo "Treating 4 * files - bestphotos in ${BESTPHOTOS_DIR} $(date)"
echo $FOUR_STARS_LIST

if [ ! -z "$FOUR_STARS_LIST" ]
then
  # TODO, we have to ignore fileNmae which are at root of famille directoyr (as they are not classified in year/month dir. We don't want to copy them in BESTPHOTOS as they were set at root and we may have duplicates if we run exiftool to order in year/month dirs)
  #  In fact, wa cannot use exiftool to order as photos need to be at the root of the directory in order for moments to make the albums
  while IFS= read -r line; do
      # BASE_DIR=`dirname $line`
      # STRIPED_BASE_DIR=${BASE_DIR#$FAMILLE_PHOTOS_LIBRARY}
      # FILE_NAME=`basename $line`
      # mkdir -p ${BESTPHOTOS_DIR}${STRIPED_BASE_DIR}
      # cp -n $line ${BESTPHOTOS_DIR}${STRIPED_BASE_DIR}/${FILE_NAME}
      # echo "Copied : ${BESTPHOTOS_DIR}${STRIPED_BASE_DIR}/${FILE_NAME}"
      mkdir -p ${BESTPHOTOS_DIR}${YEAR_TO_SEARCH}
      cp -n $line ${BESTPHOTOS_DIR}${YEAR_TO_SEARCH}/${FILE_NAME}
      echo "Copied : ${BESTPHOTOS_DIR}${YEAR_TO_SEARCH}/${FILE_NAME}"
  done <<< "$FOUR_STARS_LIST"
fi

echo "Get list of files with 5* $(date)"
FIVE_STARS_LIST=`exiftool -r -if '$XMP:rating eq 5' -p '$directory/$FileName' -T "${FAMILLE_PHOTOS_LIBRARY}${YEAR_TO_SEARCH}"`
echo "Treating 5 * files - bestphotos in ${BESTPHOTOS_DIR} $(date)"
echo $FIVE_STARS_LIST
if [ ! -z "$FIVE_STARS_LIST" ]
then
  while IFS= read -r line; do
      # BASE_DIR=`dirname $line`
      # STRIPED_BASE_DIR=${BASE_DIR#$FAMILLE_PHOTOS_LIBRARY}
      # FILE_NAME=`basename $line`
      # mkdir -p ${BESTPHOTOS_DIR}${STRIPED_BASE_DIR}
      # cp -n $line ${BESTPHOTOS_DIR}${STRIPED_BASE_DIR}/${FILE_NAME}
      # echo "Copied : ${BESTPHOTOS_DIR}${STRIPED_BASE_DIR}/${FILE_NAME}"
      mkdir -p ${BESTPHOTOS_DIR}${YEAR_TO_SEARCH}
      cp -n $line ${BESTPHOTOS_DIR}${YEAR_TO_SEARCH}/${FILE_NAME}
      echo "Copied : ${BESTPHOTOS_DIR}${YEAR_TO_SEARCH}/${FILE_NAME}"
  done <<< "$FIVE_STARS_LIST"
fi

