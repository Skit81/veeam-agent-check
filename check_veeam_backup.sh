#!/bin/bash

HOST=`hostname`
REPORT_NAME_FORMAT="%d-%m-%Y"
CURRENT_DATE_FORMAT="%d.%m.%Y"
CURRENT_TIME_FORMAT="%H:%M:%S"
REPORT_FILE=\tmp\report_$(date +$REPORT_NAME_FORMAT).log
TOKEN="000000000:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
RECIP="00000000"

# Get Veeam job list

JOB_LIST=($(awk 'NR>1 {print$1}' <<< "$(veeamconfig job list)"))
JOB_RESULT_PATH="/var/log/veeam/Backup/"

echo -e "\nStart check on $(date +$CURRENT_DATE_FORMAT) at $(date +$CURRENT_TIME_FORMAT)\n" >> $REPORT_FILE

# Check result Veeam backup job

for JOB in $JOB_LIST
        do
                echo Check Schedule job >> $REPORT_FILE
                echo name: $JOB >> $REPORT_FILE
                echo Host: $HOST >> $REPORT_FILE
                echo -e "------------------------------------------------------\n" >> $REPORT_FILE
                echo -e "$(veeamconfig schedule  show --jobName $JOB)\n" >> $REPORT_FILE
                LAST_JOB_RESULT=$(ls -t $JOB_RESULT_PATH/$JOB | head -n 1 | cut -c 25-)
                veeamconfig session info --id $LAST_JOB_RESULT | grep State >> $REPORT_FILE
        done
echo -e "------------------------------------------------------\n\n\n" >> $REPORT_FILE

# Send result to telegram if Veeam backup job filed

if [ "$(veeamconfig session info --id $LAST_JOB_RESULT | grep State | cut -d: -f2 | tr -d ' ')" = "Success" ]
then
	rm -rf $REPORT_FILE #Delete log file
else
	SEND_RESULT="$(echo -e "$(cat ${REPORT_FILE})")"
	curl --silent --data "html&text=$SEND_RESULT" https://api.telegram.org/bot$TOKEN/sendMessage?chat_id=$RECIP&parse_mode=
	rm -rf $REPORT_FILE #Delete log file
fi
