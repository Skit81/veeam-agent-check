#!/bin/bash

# PARAMETRS

HOST=`hostname`
REPORT_NAME_FORMAT="%d-%m-%Y"
CURRENT_DATE_FORMAT="%d.%m.%Y"
CURRENT_TIME_FORMAT="%H:%M:%S"
REPORT_FILE=report_$(date +$REPORT_NAME_FORMAT).log
#TOKEN="000000000:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#RECIP_ID="00000000"
REPOSITORY=" "
MOUNT_POINT=" "
# MOUNT_USER=" "
# MOUNT_PASSWORD=" "

# Get Veeam job list

JOB_LIST=($(awk 'NR>1 {print$1}' <<< "$(veeamconfig job list)"))
JOB_RESULT_PATH="/var/log/veeam/Backup/"

echo -e "\nStart check on $(date +$CURRENT_DATE_FORMAT) at $(date +$CURRENT_TIME_FORMAT)\n" >> $REPORT_FILE

# Check result Veeam backup job

for JOB in $JOB_LIST
        do
                echo ------------------------------------------------------ >> $REPORT_FILE
                echo Check Schedule job name: $JOB from Host: $HOST >> $REPORT_FILE
                echo -e "------------------------------------------------------\n" >> $REPORT_FILE
                echo -e "$(veeamconfig schedule  show --jobName $JOB)\n" >> $REPORT_FILE
                echo ------------------------------------------------------ >> $REPORT_FILE
                echo Check latest session Job name: $JOB from Host: $HOST >> $REPORT_FILE
                echo -e "------------------------------------------------------\n" >> $REPORT_FILE
                LAST_JOB_RESULT=$(ls -t $JOB_RESULT_PATH/$JOB | head -n1 | cut -c 25-)
                veeamconfig session info --id $LAST_JOB_RESULT >> $REPORT_FILE
        done
echo ------------------------------------------------------ >> $REPORT_FILE
echo Stop check on $(date +$CURRENT_DATE_FORMAT) at $(date +$CURRENT_TIME_FORMAT) >> $REPORT_FILE
echo "\n" >> $REPORT_FILE
mkdir $MOUNT_POINT
# if the repository owner is not root 
# mount -t cifs -o user=$MOUNT_USER,password=$MOUNT_PASSWORD $REPOSITORY $MOUNT_POINT
mount -t cifs $REPOSITORY $MOUNT_POINT
echo ------------------------------------------------------ >> $REPORT_FILE
echo -e "Check files in backup repository:\n" >> $REPORT_FILE
ls -h $MOUNT_POINT >> $REPORT_FILE
echo ------------------------------------------------------ >> $REPORT_FILE
echo -e "Check free space on backup repository:\n" >> $REPORT_FILE
echo -e "$(df -h $MOUNT_POINT)\n" >> $REPORT_FILE
echo -e "------------------------------------------------------\n\n\n" >> $REPORT_FILE
sleep 30
umount $MOUNT_POINT
rm -rf $MOUNT_POINT

SEND_RESULT="$(echo -e "$(cat ${REPORT_FILE})")"

# Send result to telegram
# Uncomment the next line to send results to telegram
# curl --silent --data "html&text=$SEND_RESULT" https://api.telegram.org/bot$TOKEN/sendMessage?chat_id=$RECIP_ID&parse_mode=

# Send result to email
# Uncomment the next line to send the results by email and replace <your_mail@yuor_domain>
# mail -s "Report $HOST - $(date +$CURRENT_DATE_FORMAT)" your_mail@yuor_domen < $REPORT_FILE

# if you want delete report file, uncomment next line 
# rm -rf $REPORT_FILE #Delete log file
