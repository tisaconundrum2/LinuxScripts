#!/bin/bash
#
# CIDSE WORKSTATION CONFIG
#		version 1.0
#	created by: James White
# 	Contributors: William Flemming
# 	Contributors: Nicholas Finch
#
#	CIDSE IT
#	Arizona State University
#	last updated July 17, 2018
##
##							   ##
## BIND TO ACTIVE DIRECTORY   ##
##							   ##

joinDomain(){
		# Join FULTON.AD.ASU.EDU
		echo "Joining this machine to Active Directory"
		domainjoin-cli join fulton.ad.asu.edu
}

loginPBIS_OPEN(){
		# Configure Login PBIS-OPEN
		/opt/pbis/bin/config UserDomainPrefix ASUAD
		/opt/pbis/bin/config AssumeDefaultDomain true
		/opt/pbis/bin/config LoginShellTemplate /bin/bash
		#/opt/pbis/bin/config HomeDirTemplate %H/%U
		#/opt/pbis/bin/config RequireMembershipOf
}

preConfigureLandscape(){
		# PRE-CONFIGURE
		# LANDSCAPE CLIENT
		# CONFIGURE .host FILE
		cat /install/fse/host/addhost.txt >> /etc/hosts
		# Configure /etc/landscape/ directory  ###
		## Copying Landscape License File ##
		cp /install/fse/landscape/license.txt /etc/landscape/
		## Copy Landscape SSL Cert to /etc/landscape ##
		cp /install/fse/landscape/landscape_server.pem /etc/landscape/
		## Make backup of default client.conf    ##
		mv /etc/landscape/client.conf /etc/landscape/client.conf.bak
		# Write Client.txt data to the client.conf file ###
		cp /root/install/fse/landscape/client.conf /etc/landscape/
		## Request Client registration from Landscape  ###
		echo "Beginning Landscape Configuration"
		landscape-config --computer-title "$(hostname -f)" --script-users nobody,landscape,root --silent
}

addAdminstrators(){
	# ADD ADMINISTRATORS
		return 0
}

addPrinters(){
	# ADD PRINTERS
	sh /mnt/source/linux/ubuntu/config/cidse/workstation/printers/cidse_printers_byeng.sh
}

setBaseSoftware(){
	# INSTALL BASE SOFTWARE
	# ALL COMMON SOFTWARE CAN BE FOUND Here:
	# /mnt/source/linux/software/common
	# cidse-fs-01.cidse.dhcp.asu.edu/linux/software
	echo "Installing MATLAB2017a"
	sh /mnt/source/linux/ubuntu/software/common/matlab/R2017a/install_matlab2017a.sh
	echo "Installing VMWARE 14 with Windows 10 VM"
	sh /mnt/source/linux/ubuntu/software/common/vmware/14/install_vmware14.0.0.sh

}

setDepartmentSoftware(){
	# INSTALL DEPARTMENT SPECIFIC SOFTWARE
	# CIDSE SPECIFIC SOFTWARE CAN BE FOUND Here:
	# /mnt/source/linux/software/cidse
	# cidse-fs-01.cidse.dhcp.asu.edu/linux/software/cidse
        return 0
}

setThePickles(){
	# EXTRA PICKLES
	return 0
}

setTechProfile(){
	# COPY TECHS PROFILE TEMPLATE
	rm -r /home/techs/
	cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/techs/ /home/
	chown -R techs /home/techs/
}

setDefaultUserProfile(){
	# COPY DEFAULT USER PROFILE
	# cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/default/. /etc/skel; \
	return 0
}

setDesktopBackground(){
	# Copy the Fulton background to the default location and file
	echo "Copying CIDSE 2018 Wallpaper"
	rm /usr/share/backgrounds/warty-final-ubuntu.png
	cp /mnt/source/linux/ubuntu/config/cidse/workstation/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/
	chown root:root /usr/share/backgrounds/warty-final-ubuntu.png
	chmod 744 /usr/share/backgrounds/warty-final-ubuntu.png
}

setLoginConfiguration(){
	# Set Login Configuration
	# Lightdm.conf file is set to allow TECHS to auto login
	echo "Copying Lightdm.conf"
	rm /etc/lightdm/lightdm.conf
	cp /mnt/source/linux/ubuntu/config/cidse/workstation/login/lightdm.conf /etc/lightdm/lightdm.conf
	chown root:root /etc/lightdm/lightdm.conf
	chmod a+x /etc/lightdm/lightdm.conf
}

setCIDSEIT(){
	# Copy Next Startup Script
	mkdir /cidseit/
	mkdir /cidseit/login/
	mkdir /cidseit/login/scripts/
	mkdir /cidseit/login/scripts/startup/
	chown -R techs /cidseit/
}

makeRCLocal(){
	# Places permanent rc.local file in /etc/
		cp /mnt/source/linux/ubuntu/config/cidse/workstation/login/scripts/startup/rc.local /etc/rc.local
		chmod +x /etc/rc.local
}

makeGroupAdmins(){
	# Make Group Admins
	# Add the CIDSE-IT group to admins
	CidseItGroup='%FULTON\\\\\\cidse-it	ALL=(ALL:ALL) ALL'
	echo "$CidseItGroup" >> /etc/sudoers
}

addOtherGroups(){
	# check to see if they want to add other groups
	answer='N'
	read -rp 'would you like to add a group to the sudo file? [y/N] ' answer

	if [[ $answer = [yY] ]]
	then
		# get the groupname
		echo 'enter groupname without the FULTON\ prefix'
		echo 'the standad lab admin groupname is "CIDSE-#professor ASUAD#_Lab_Admins"'
		echo 'for example, "CIDSE-adoipe1_Lab_Admins"'
		read -r Group
		Group="%FULTON\\\\\\$Group	ALL=(ALL:ALL) ALL"
		#add to the sudo file
		echo "$Group" >> /etc/sudoers
	fi
}


runGPUInstall(){
	# Run GPU Script
	# check to see if they want to un GPU script
	# We really should have a wget set on this script instead of having a copy of it
	# directly in the main script
	answerGPU='N'
	echo 'would you like to run gpu script [y/N]'
	read -r answerGPU
	if [[ $answerGPU = [yY] ]]
		wget
	then

}

runCleanUp(){
	# CLEAN UP
	rm /home/techs/Desktop
	mkdir /var/log/fse/cidse
	touch /var/log/fse/cidse/workstation_config.txt
	echo "CLIENT CONFIGURATION COMPLETE"
	sleep 10
	reboot
}
