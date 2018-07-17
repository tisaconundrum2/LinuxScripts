#!/bin/bash
#### Get Host Name ####
echo 'enter hostname in \"enXXXXXXXl\" format'
read -r HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to Host and Run Commands ####
echo 'Enter the admin Password when prompted'
ssh -t "$HOST" '
echo "please enter the ASURITE of the user to become admin"
read username
sudo adduser $username sudo'
