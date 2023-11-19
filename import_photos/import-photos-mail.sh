#!/bin/bash

# http://www.launchd.info
# http://www.soma-zone.com/LaunchControl/

# Automatisation du lancement : Via le photoimporter.plist qui est déposé dans : ~/Library/LaunchAgents/com.multiseb.photoimporter.plist  (du user Doux)
# Par contre pour fonctionner, cela nécessite que le user doux se soit loggué une fois au redémarrage de la machine, sinon il faudrait le mettre dans /System/Library/LaunchDaemons  (à relire et vérifier/tester dans https://www.launchd.info/)



LOG_FILE="/Users/doux/Documents/Dev-tools-utils-projects/scripts/import-photos-mail.output.log"
TEMP_RESULT_FILE="/tmp/import-photos-mail-temp-results.txt"

DATE=`date`
echo "###################################################" >> $LOG_FILE
echo "BEGIN New execution of script import-photos-mail.sh" >> $LOG_FILE
echo "$DATE" >> $LOG_FILE


# Redirect stodut to file then redirect stderr to stdout
# https://stackoverflow.com/questions/314675/how-do-i-redirect-the-output-of-an-entire-shell-script-within-the-script-itself/314678
exec >$TEMP_RESULT_FILE 2>&1
/Users/doux/Documents/Dev-tools-utils-projects/scripts/import-photos.sh



echo "Running... results below " >> $LOG_FILE
cat $TEMP_RESULT_FILE | grep -v 'Building file list' | grep -v 'Progress ' >> $LOG_FILE

echo "Sending result via email to seb54000@gmail.com" >> $LOG_FILE
cat $TEMP_RESULT_FILE | grep -v 'Building file list' | grep -v 'Progress ' | /usr/bin/mail -s "import photos job report" "seb54000@gmail.com" >> $LOG_FILE


DAY_IN_WEEK=$(date +%w)
if [ $DAY_IN_WEEK -eq 4 ]
then
    echo "Sending reminder email : launch dropbox on iPhone to synchronize photos and videos to seb54000@gmail.com , carole" >> $LOG_FILE
    echo "REMINDER : Launch dropbox to synchronize photos and videos" | /usr/bin/mail -s "REMINDER : Launch dropbox to synchronize photos and videos" "seb54000@gmail.com" >> $LOG_FILE
    echo "REMINDER : Launch dropbox to synchronize photos and videos" | /usr/bin/mail -s "REMINDER : Launch dropbox to synchronize photos and videos" "carolegrandidier@gmail.com" >> $LOG_FILE
fi


# mail seems to work only with this in plist file : https://discussions.apple.com/thread/2523408
#  <key>AbandonProcessGroup</key>
#  <true/>
# And also need to unload and load the job in launchcontrol 

#launchctl unload ~/Library/LaunchAgents/com.example.app.plist
#launchctl load ~/Library/LaunchAgents/com.example.app.plist
# test with launchctl start com.example.app

DATE=`date`
echo "$DATE" >> $LOG_FILE
echo "END of execution" >> $LOG_FILE
echo "###################################################" >> $LOG_FILE

# Mail config postfix
#  Dans /etc/postfix/main.cf 

#https://www.justinsilver.com/technology/osx/send-emails-mac-os-x-postfix-gmail-relay/
# CONFIG qui fonctionne !!!
# inet_protocols = ipv4 est essentiel !!!!

#Comment afficher les logs sur smpt dans MAC SIERRA
#https://apple.stackexchange.com/questions/276322/where-is-the-postfix-log-on-sierra
#log stream --predicate  '(process == "smtpd") || (process == "smtp")' --info

# Stat conf of /etc/postfix/main.cf

# # Gmail SMTP relay
# relayhost = [smtp.gmail.com]:587

# # Enable SASL authentication in the Postfix SMTP client.
# smtpd_sasl_auth_enable = yes
# smtp_sasl_auth_enable = yes
# smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
# ### put in plain text a dedicated app password : https://myaccount.google.com/security
# ### sudo postmap /etc/postfix/sasl_passwd
# smtp_sasl_security_options =
# #smtp_sasl_mechanism_filter = AUTH LOGIN
# smtp_sasl_mechanism_filter = plain

# # Enable Transport Layer Security (TLS), i.e. SSL.
# smtp_use_tls = yes
# smtp_tls_security_level = encrypt
# tls_random_source = dev:/dev/urandom

# #inet_protocols = all
# inet_protocols = ipv4