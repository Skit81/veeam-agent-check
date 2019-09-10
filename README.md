# veeam-agent-check
Bash script for check result job veeam agent linux


1. git clone https://github.com/Skit81/veeam-agent-check.git

2. nano check_veeam_backup.sh

REPOSITORY=" " # path to repository

MOUNT_POINT=" " # local mount point

MOUNT_USER=" " # if the repository owner is not root

MOUNT_PASSWORD=" " # if the repository owner is not root


For report in telegram:
#TOKEN="000000000:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #Telegram bot token
#RECIP_ID="00000000" #Telegram user or chat id

3. chmod +x check_veeam_backup.sh

4. Test script:

./check_veeam_backup.sh > /dev/null

5. Add to crontab

crontab -e

0 9 * * * /scripts/check_veeam_backup.sh > /dev/null # Daily check at 9am
