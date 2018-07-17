#!/bin/bash
#### Get Host Name ####
echo 'enter hostname in "enXXXXXXXl" format'
read -r HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to the System ####
ssh -t "$HOST" '
#### Run Commands ####
read -rsp "Password:" pwd
echo
echo "Please enter groupname without prefix"
echo "The standad lab admin groupname is: \"CIDSE-<professor ASUAD>_Lab_Admins\""
echo "Example: CIDSE-adoipe1_Lab_Admins"
read -r Group
Group="%FULTON\\\\\\$Group	ALL=(ALL:ALL) ALL"
# add to the sudo file
echo $pwd | sudo -S cat /etc/sudoers > /tmp/sudoers.tmp
echo $pwd | sudo -S echo "$Group" >> /tmp/sudoers.tmp
clear
echo "Output of sudoers file"
echo
echo $pwd | sudo -S cat /tmp/sudoers.tmp
echo
read -rp "Do the contents of the file look correct? [y/N] " answer

if [[ $answer = [yY] ]]; then
    echo $pwd | sudo -S cp /tmp/sudoers.tmp /etc/sudoers
else
    echo "Not commiting changes. Now exiting"
fi
rm /tmp/sudoers.tmp
'
