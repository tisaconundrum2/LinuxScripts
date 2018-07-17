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

getBaseSoftware(){
	# INSTALL BASE SOFTWARE
	# ALL COMMON SOFTWARE CAN BE FOUND Here:
	# /mnt/source/linux/software/common
	# cidse-fs-01.cidse.dhcp.asu.edu/linux/software
	echo "Installing MATLAB2017a"
	sh /mnt/source/linux/ubuntu/software/common/matlab/R2017a/install_matlab2017a.sh
	echo "Installing VMWARE 14 with Windows 10 VM"
	sh /mnt/source/linux/ubuntu/software/common/vmware/14/install_vmware14.0.0.sh

}

getDepartmentSoftware(){
	# INSTALL DEPARTMENT SPECIFIC SOFTWARE
	# CIDSE SPECIFIC SOFTWARE CAN BE FOUND Here:
	# /mnt/source/linux/software/cidse
	# cidse-fs-01.cidse.dhcp.asu.edu/linux/software/cidse

}

getThePickles(){
	# EXTRA PICKLES
	return 0
}

getTechProfile(){
	# COPY TECHS PROFILE TEMPLATE
	rm -r /home/techs/
	cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/techs/ /home/
	chown -R techs /home/techs/
}

getDefaultUserProfile(){
	# COPY DEFAULT USER PROFILE
	# cp -r /mnt/source/linux/ubuntu/config/cidse/workstation/profiles/default/. /etc/skel; \
	return 0
}

getDesktopBackground(){
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

#check to see if they want to add other groups
answer='N'
read -rp 'would you like to add a group to the sudo file? [y/N] ' answer

if [[ $answer = [yY] ]]
then
	#get the groupname
	echo 'enter groupname without the FULTON\ prefix'
	echo 'the standad lab admin groupname is "CIDSE-#professor ASUAD#_Lab_Admins"'
	echo 'for example, "CIDSE-adoipe1_Lab_Admins"'
	read -r Group
	Group="%FULTON\\\\\\$Group	ALL=(ALL:ALL) ALL"
	#add to the sudo file
	echo "$Group" >> /etc/sudoers
fi

#
#
#               Run GPU Script            #
#
#

#check to see if they want to un GPU script
answerGPU='N'
echo 'would you like to run gpu script [y/N]'
read -r answerGPU
if [[ $answerGPU = [yY] ]]
then

	#!/bin/bash
	##
	#
	#            MUST BE RUN WITH COMMAND BELOW
	#            sudo bash "PATH TO THIS FILE"
	#            Created By: Jonah Procyk
	#            Date: 4/10/18
	#
	#            Contributors
	#            Nicholas Finch
	#
	##


	#Detect Graphics Card
	GCard=$(lspci -v | grep -c "NVIDIA")
	InstallC="y"
	Install="y"
	CudaVersion=0

	if [ "$GCard" != 0 ]; then
	  echo "Nvidia Graphics Card Detected, Proceeding with Install"
	else
	  read -rp "No Nvidia Graphics Card Detected, Would you like to proceed with installation? [y/n]: " Install
	fi


	if [ -d  /usr/local/cuda-8.0/ ] || [ -d /usr/local/cuda-9.0/ ]; then  ##Checks to See if CUDA 8 or 9 is Installed
	  read -rp "CUDA is already installed! Do you want to reinstall? [y/n] : " InstallC ## If it is, offers reinstallation
	fi


	while [ $CudaVersion != 8 ] && [ $CudaVersion != 9 ]; do
	  read -rp "Which Version of Cuda Would you Like? (8/9) : " CudaVersion
	done

	if [[ "$Install" == [yY] ]] && [[ "$InstallC" == [yY] ]]; then  ## Starts Installation/Reinstallation
	  ##Remove any drivers already on machine
	  echo "Removing old Nvidia and Cuda Drivers"
	  sudo apt-get remove nvidia* -y
	  sudo apt-get autoremove -y
	  sudo rm -R /usr/local/cuda-8.0/
	  sudo rm -R /usr/local/cuda-9.0/
	  ## Make sure computer is up to date
	  echo "Updating Dependencies (Estimated 2 min)"
	  sudo apt-get install dkms build-essential linux-headers-generic -y
	  sudo apt-get install gcc -y
	  sudo apt-get install linux-headers-"$(uname -r)" -y
	  echo "Updating Computer (Estimated 3-5 min)"
	  sudo apt-get update -y
	  sudo apt-get upgrade -y
	  sudo apt-get install gzip -y
	  ##Change option from quiet splash to nosplash in Grub#
	  sudo sed -i -e 's/quiet splash/nosplash/' '/etc/default/grub'
	  sudo update-grub
	  echo "Grub Updated"
	  ##Blacklist Nouveau#
	  BlackNouveau=$(grep -c 'blacklist nouveau' /etc/modprobe.d/blacklist.conf) ##Checks to See if Nouveau is Already Blacklisted
	  if [ "$BlackNouveau" -eq 0 ]; then
	    echo "blacklist nouveau" >> '/etc/modprobe.d/blacklist.conf'
	    echo "blacklist lbm-nouveau" >> '/etc/modprobe.d/blacklist.conf'
	    echo "options nouveau off" >> '/etc/modprobe.d/blacklist.conf'
	    echo "alias nouveau off" >> '/etc/modprobe.d/blacklist.conf'
	    echo "alias lbm-nouveau off" >> '/etc/modprobe.d/blacklist.conf'
	    echo "Nouveau Blacklisted"
	  else
	    echo "Nouveau Already Blacklisted"
	fi
	#Update Boot Settings so Nouveau won’t be used#
	sudo update-initramfs -u
	#Add Nvidia Graphics Driver Repository
	echo "Adding Graphics Driver Repository"
	echo | sudo add-apt-repository ppa:graphics-drivers
	sudo apt-get update
	##Connect to FS-01 for software repository
	echo "Installing CIFS-UTILS"
	sudo apt-get install cifs-utils -y
	echo "Making New Source Directory"
	mkdir /mnt/source/
	echo "Mounting CIDSE-FS-01"
	mount.cifs //cidse-fs-01.cidse.dhcp.asu.edu/Source /mnt/source -o vers=3.0,username=deploy,domain=cidse-fs-01,password=hiywabk2DAY!


	if [ "$CudaVersion" = 8 ]; then
	  #Download Cuda Run File#
	  echo "Downloading Cuda 8 Run File"
	  sudo wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run -P "/home/$USER/Downloads/"
	  #Run Cuda Installer (Installs Cuda 8.0 and Samples to /usr/lib/)
	  sudo chmod 777 "/home/$USER/Downloads/cuda_8.0.61_375.26_linux-run"
	  echo "Extracting Cuda Installer and Samples"
	  sudo sh "/home/$USER/Downloads/cuda_8.0.61_375.26_linux-run" --extract=/home/$USER/Downloads
	  echo "Installing Cuda"
	  sudo sh "/home/$USER/Downloads/cuda-linux64-rel-8.0.61-21551265.run" --noprompt
	  if [ -d "/usr/local/cuda-8.0/" ]; then
	    echo "Cuda Installation Successful"
	  else
	    echo "Cuda Installation Unsuccessful"
	  fi
	  sudo sh "/home/$USER/Downloads/cuda-samples-linux-8.0.61-21551265.run" --noprompt --cudaprefix=/usr/local/cuda-8.0/
	  if [ -d "/usr/local/cuda-8.0/samples" ]; then
	    echo "Samples Copied to Correct Directory"
	  else
	    echo "Samples not copied to Correct Directory"
	  fi

	  #Install CuDNN v6.0
	  echo "Downloading CuDNN v6"
	  CUDNN_TAR_FILE="cudnn-8.0-linux-x64-v6.0.tgz"
	  sudo wget 'http://developer.download.nvidia.com/compute/redist/cudnn/v6.0/cudnn-8.0-linux-x64-v6.0.tgz' -P "/home/$USER/Downloads/"
	  sudo tar -xzvf "/home/$USER/Downloads/${CUDNN_TAR_FILE}"
	  echo "Installing CuDNN v6"
	  sudo cp -P cuda/include/cudnn.h '/usr/local/cuda-8.0/include/'
	  sudo cp -P cuda/lib64/libcudnn* '/usr/local/cuda-8.0/lib64/'
	  sudo chmod a+r /usr/local/cuda-8.0/lib64/libcudnn*
	  if [ -f "/usr/local/cuda-8.0/include/cudnn.h" ]; then
	    echo "Cudnn Installed"
	  else
	    echo "Cudnn Not Installed"
	  fi

	  #Export Variables
	  echo "Exporting Variables"
	  export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
	  export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

	  #Post Install Libraries (Useful for the install of Tensorflow etc)
	  echo "Installing Libraries"
	  sudo apt-get install g++ freeglut3-dev build-essential libx11-dev libxmu-dev
	  sudo apt-get install libxi-dev libglu1-mesa libglu1-mesa-dev

	  echo .
	  echo .
	  echo .
	  echo .
	  echo .
	  echo .
	  echo "STOP! Please Install your graphics card drivers now"
	  read -p "Press [Enter] key to start tests..."

	  #Make CUDA Samples
	  echo "Making Cuda Samples Utilities"
	  sudo make -C '/usr/local/cuda-8.0/samples/1_Utilities/bandwidthTest/'


	  #Test CUDA
	  if [ -e '/usr/local/cuda-8.0/samples/1_Utilities/bandwidthTest/bandwidthTest' ]; then
	    touch /tmp/band.txt
	    chmod 777 /tmp/band.txt
	    /usr/local/cuda-8.0/samples/1_Utilities/bandwidthTest/bandwidthTest >> /tmp/band.txt
	    grep 'Device 0' /tmp/band.txt
	    grep 'Device 1' /tmp/band.txt
	    grep 'Result = ' /tmp/band.txt
	    rm /tmp/band.txt
	  else
	    echo "Samples Not Installed Correctly"
	  fi

	  echo "Installation Complete"

	elif [ $CudaVersion = 9 ]; then

	  #Download Cuda Run File
	  echo "Downloading Cuda 9 Run File"
	  wget https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda_9.0.176_384.81_linux-run -P "/home/$USER/Downloads"

	  #Run Cuda Installer (Installs Cuda 9.0 and Samples to /usr/lib/
	  sudo chmod 777 "/home/$USER/Downloads/cuda_9.0.176_384.81_linux-run"
	  echo "Extracting Cuda Installer and Samples"
	  sudo sh "/home/$USER/Downloads/cuda_9.0.176_384.81_linux-run" --extract=/home/$USER/Downloads
	  echo "Installing Cuda V9"
	  sudo sh "/home/$USER/Downloads/cuda-linux.9.0.176-22781540.run" --noprompt
	  if [ -d "/usr/local/cuda-9.0/" ]; then
	    echo "Cuda Installation Successful"
	  else
	    echo "Cuda Installation Unsuccessful"
	  fi
	  sudo sh "/home/$USER/Downloads/cuda-samples.9.0.176-22781540-linux.run" --noprompt --cudaprefix=/usr/local/cuda-9.0/
	  if [ -d "/usr/local/cuda-9.0/samples" ]; then
	    echo "Samples Copied to Correct Directory"
	  else
	    echo "Samples not copied to Correct Directory"
	  fi

	  #Install CuDNN v7.1
	  echo "Downloading CuDNN v7.1"
	  sudo cp "/mnt/source/linux/ubuntu/config/cidse/scripts/GPU Setup/Software/cudnn-9.1-linux-x64-v7.1.tgz" "/home/$USER/Downloads/"
	  CUDNN_TAR_FILE="cudnn-9.1-linux-x64-v7.1.tgz"
	  sudo tar -xzvf "/home/$USER/Downloads/${CUDNN_TAR_FILE}"
	  sudo cp -P cuda/include/cudnn.h '/usr/local/cuda-9.0/include/'
	  sudo cp -P cuda/lib64/libcudnn* '/usr/local/cuda-9.0/lib64/'
	  sudo chmod a+r /usr/local/cuda-9.0/lib64/libcudnn*
	  if [ -f "/usr/local/cuda-9.0/include/cudnn.h" ]; then
	    echo "Cudnn Installed"
	  else
	    echo "Cudnn Not Installed"
	  fi

	  #Export Variables
	  echo "Exporting Variables"
	  export PATH=/usr/local/cuda-9.0/bin${PATH:+:${PATH}}
	  export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

	  #Post Install Libraries
	  sudo apt-get install g++ freeglut3-dev build-essential libx11-dev libxmu-dev
	  sudo apt-get install libxi-dev libglu1-mesa libglu1-mesa-dev

	  echo .
	  echo .
	  echo .
	  echo .
	  echo .
	  echo .
	  echo "STOP! Please Install your graphics card drivers now"
	  read -p "Press [Enter] key to start tests..."

	  #Make CUDA Samples
	  echo "Making Cuda Samples Utilities"
	  sudo make -C '/usr/local/cuda-9.0/samples/1_Utilities/bandwidthTest/'

	  #Test CUDA
	  if [ -e '/usr/local/cuda-9.0/samples/1_Utilities/bandwidthTest/bandwidthTest' ]; then
	    touch /tmp/band.txt
	    chmod 777 /tmp/band.txt
	    /usr/local/cuda-9.0/samples/1_Utilities/bandwidthTest/bandwidthTest >> /tmp/band.txt
	    grep 'Device 0' /tmp/band.txt
	    grep 'Device 1' /tmp/band.txt
	    grep 'Result = ' /tmp/band.txt
	    rm /tmp/band.txt
	  else
	    echo "Samples Not Installed Correctly"
	  fi

	  echo " "
	  echo "Installation Finished"
	  echo " "
	fi

	else
	  echo "No Programs or Packages were installed"

	fi
fi

#
#
#                 CLEAN UP                #
#
#
rm /home/techs/Desktop
mkdir /var/log/fse/cidse
touch /var/log/fse/cidse/workstation_config.txt

echo "CLIENT CONFIGURATION COMPLETE"

sleep 10
reboot
