#### Get Host Name ####
echo 'enter hostname in "enXXXXXXXl" format'
read HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'

#### Connect to the System ####
echo 'Enter Techs password When Prompted'
ssh -t $HOST '
sudo /opt/pbis/bin/lwsm restart lsass
sudo domainjoin-cli leave fulton.ad.asu.edu
sudo domainjoin-cli join fulton.ad.asu.edu
sudo reboot'

