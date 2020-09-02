#!/bin/bash

if [-d /etc/rpi-issue ]
then 
sudo apt update 
sudo apt upgrade -y

CURRENTDIR=$(pwd)
cd ~/
HOMEDIR=$(pwd)

#Name for file share directory
echo "What would you like to name your file share? (i.e Piserver) : "
read $FSHARENAME
echo "You named your file share folder : $FSHARENAME"
echo "."
sleep 1
echo "."
sleep 1
echo "."
sleep 1
echo "."


#locate and choose the drive you intend to use
echo "Lets Locate the drive you want to use for your server"
	lslbk #list attached drives
sleep 3

echo "Please type the sda(#) you want to use for your server Example: sda1"
read $DRIVE1

#format drive or skip this step
echo "Do you want to format drive? (Ereases all data)"
	echo "1 - No I just want to share this drive"
	echo "2 - Yes, Lets start from scratch"

read -p "Share drive or wipe and format?" DRIVEFORMAT

case $DRIVEFORMAT in
	1) echo "Skipping format of disk" ;;
	2) mkfs.ext4 /dev/${DRIVE1} ;;
esac

#install samba and related needed utilities
echo "Installing Samba and other needed utilities..."
sleep 5

sudo apt install ntfs-3g -y
sudo apt install exfat-utils exfat-fuse -y
sudo apt install samba samba-common-bin -y

#reate directory based on user input name and mount drive to directory
echo "Creating File Share Directory ${HOMEDIR}/${FSHARENAME}"
sleep 3

sudo mkdir ${HOMEDIR}/${FSHARENAME}
sudo chmod 777 ${HOMEDIR}/${FSHARENAME}
sudo mount /dev/${DRIVE1} ${HOMEDIR}/${FSHARENAME}

#write configuration to /etc/samba/smb.conf
echo "writing important stuff to smb.conf file"
sleep 3

echo >> /etc/samba/smb.conf
"[$FSHARENAME]
  comment = $FSHARENAME 
  path = ${HOMEDIR}/${FSHARENAME}
  browseable = yes 
  read only = no 
  writeable= yes 
  create mask = 0777 
  directory mask = 0777 
  public = no
  force user = root"
echo "."
sleep 1
echo "."
sleep 1
echo "."
sleep 1
echo "."


#Create new user for samba network share
echo "You need to create a system user account for your share to use"
echo "Please create a new user: "
read -p NEWUSER

sudo adduser $NEWUSER

echo "now we need to create a passord for accessing your network share"
read -p SMBPASSWD

sudo smbpasswd -a $SMBPASSWD


#Set dedicated IP address for yoru raspberry PI
#echo "1 - Yes Please use dedicated IP"
#echo "2 - No Ill do this later"

exit



