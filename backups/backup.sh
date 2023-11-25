#!/bin/bash

# Emplacement du partage NAS monté
NAS_MOUNT="/mnt/backup"

# Répertoire de sauvegarde sur le NAS
BACKUP_DIR="$NAS_MOUNT/backup_home/$(hostname)"

# Répertoires HOME des utilisateurs à sauvegarder
USERS_HOME_DIR="/home/*"

# Journal des opérations
LOG_DIR="$NAS_MOUNT/backup_logs/$(hostname)"
LOG_FILE="$LOG_DIR/rsync_backup_$(date +%Y%m%d).log"

# Répertoire d'historique
HISTORY_DIR="$NAS_MOUNT/backup_history/$(hostname)"
HISTORY_PREFIX="backup_"

# Limite de taille globale (en Mo) pour les archives
SIZE_LIMIT=2000

# Enregistrez le début du temps d'exécution
START_TIME=$(date +%s)

# Créer le répertoire d'historique s'il n'existe pas
mkdir -p $HISTORY_DIR $LOG_DIR $BACKUP_DIR

# Vérifier si l'archive quotidienne existe déjà
ARCHIVE_EXISTS=false
ARCHIVE_FILE="$HISTORY_DIR/$HISTORY_PREFIX$(date +%Y%m%d).tar.gz"
if [ -e $ARCHIVE_FILE ]; then
    ARCHIVE_EXISTS=true
fi

echo "Let's see who is launching this job through whoami : $(whoami)" >> $LOG_FILE

# Trouver tous les fichiers .iface_socket sous .dropbox
EXCLUDE_FILES=$(cd /home/seb && find * -type f -name '.iface_socket*' -printf '--exclude=%p')


# Exécuter rsync pour la sauvegarde
# https://stackoverflow.com/questions/30671292/running-rsync-as-root-operations-not-permitted
# rsync -rltgoDv --delete --exclude='*/.cache/' \
rsync -av --delete --exclude='*/.cache/' \
    $EXCLUDE_FILES \
    --exclude='seb/Dropbox/' --exclude='*/snap/' --exclude='*/.config/google-chrome/' \
    --exclude='*/.thunderbird/*/ImapMail/imap.gmail.com/' \
    --exclude='*/.thunderbird/*/lock' \
    --exclude='*/.dropbox-dist/' \
    --exclude='seb/.dropbox-carole/.dropbox-dist/' \
    --exclude='*/.dropbox/.command_socket*' \
    --exclude='*/.dropbox/.iface_socket*' \
    --exclude='seb/.dropbox-carole/.dropbox/.command_socket*' \
    --exclude='seb/.dropbox-carole/.dropbox/.iface_socket*' \
    $USERS_HOME_DIR $BACKUP_DIR >> $LOG_FILE 2>&1

# Vérifier si rsync a réussi
if [ $? -eq 0 ]; then
    # Enregistrement de la date et de l'heure de la sauvegarde dans le journal
    echo "Sauvegarde effectuée le $(date)" >> $LOG_FILE

    # Ecraser l'archive quotidienne si elle existe déjà
    if [ "$ARCHIVE_EXISTS" = true ]; then
        rm $ARCHIVE_FILE
    fi

    # Archiver la sauvegarde quotidienne dans l'historique
    tar -czf $ARCHIVE_FILE -C $NAS_MOUNT $(basename $BACKUP_DIR)
else
    # Enregistrement d'une erreur dans le journal
    echo "Erreur lors de l'exécution de rsync. Veuillez vérifier le journal." >> $LOG_FILE
    echo -e "Subject:WARNING : Backup failed at rsync step for $(hostname)\n\nReview the logs at $LOG_FILE for $(hostname)" | sudo msmtp seb54000@gmail.com
fi

# Supprimer les archives excédentaires (garder les 5 dernières)
ARCHIVE_COUNT=$(ls -1 $HISTORY_DIR/$HISTORY_PREFIX* 2>/dev/null | wc -l)

if [ $ARCHIVE_COUNT -gt 5 ]; then
    # Liste des archives, triées par date (la plus ancienne d'abord)
    ARCHIVE_LIST=$(ls -t $HISTORY_DIR/$HISTORY_PREFIX* 2>/dev/null)

    # Supprimer les archives excédentaires (au-delà des 5 dernières)
    DELETE_COUNT=$((ARCHIVE_COUNT - 5))
    echo "$ARCHIVE_LIST" | tail -n $DELETE_COUNT | xargs rm

    # Liste des fichiers de log, triés par date (les plus anciens d'abord)
    LOG_LIST=$(ls -t $LOG_DIR/rsync_backup_*.log 2>/dev/null)

    # Supprimer les fichiers de log excédentaires (au-delà des 5 derniers)
    DELETE_COUNT=$((LOG_COUNT - 5))
    echo "$LOG_LIST" | tail -n $DELETE_COUNT | xargs rm
fi

# Calculer la taille totale des archives
TOTAL_SIZE=$(du -m $HISTORY_DIR | awk '{total+=$1} END{print total}')

# Enregistrer la taille totale dans le journal
echo "Taille totale des archives : ${TOTAL_SIZE} Mo" >> $LOG_FILE

# Vérifier si la taille dépasse la limite
if [ $TOTAL_SIZE -gt $SIZE_LIMIT ]; then
    echo "Attention : La taille totale des archives dépasse la limite de ${SIZE_LIMIT} Mo." >> $LOG_FILE
    echo -e "Subject:WARNING : Backup size limit reached for $(hostname)\n\nLa taille totale des archives dépasse la limite de ${SIZE_LIMIT} Mo. on $(hostname)" | sudo msmtp seb54000@gmail.com
fi

# Enregistrez la fin du temps d'exécution
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

# Enregistrez le temps d'exécution dans le journal
echo "Temps d'exécution : ${ELAPSED_TIME} secondes" >> $LOG_FILE


# TODO should also think about doing it in a tar locally before rsync (today it is long to do the rsync and there are still somme rbac issues
# https://chat.openai.com/c/30786aec-3510-47fe-aaff-90a6f0cb26be)