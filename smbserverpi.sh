#!/bin/bash

if [ -d /etc/apt ]
then 
sudo apt update 
sudo apt upgrade -y
fi

CURRENTDIR=$(pwd)
cd ~/
HOMEDIR=$(pwd)

#Name for file share directory
echo "You need to choose a name for your file share"
read -p "What Would You like to name your network share?: " FSHARENAME
echo "."
sleep 1
echo "."
sleep 1
echo "."
sleep 1
echo "."


#locate and choose the drive you intend to use
echo "Lets Locate the drive you want to use for your server"
	lsblk #list attached drives
sleep 3

read -p "Type the drive name you want to use for your server (ie. sda): " DRIVE1

#format drive or skip this step
echo "Do you want to format drive? (Ereases all data)"
	echo "1 - No I just want to share this drive"
	echo "2 - Yes, Lets start from scratch"

read -p "1 or 2?: " DRIVEFORMAT

sudo umount /dev/${DRIVE1} /dev/sda1 /dev/sda2 /dev/sda3

case $DRIVEFORMAT in
	1) echo "Skipping format of disk" ;;
	2) sudo mkfs.ext4 /dev/${DRIVE1} ;;
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

echo "Mounting the drive to your new $FSHARENAME directory"
sleep 3
sudo mount /dev/${DRIVE1} ${HOMEDIR}/${FSHARENAME}

#write configuration to /etc/samba/smb.conf
echo "writing important stuff to smb.conf file"
sleep 3

sudo sh -c echo "[$FSHARENAME]
  comment = $FSHARENAME 
  path = ${HOMEDIR}/${FSHARENAME}
  browseable = yes
  read only = no
  writeable= yes
  create mask = 0777
  directory mask = 0777
  public = no
  force user = root" >> /etc/samba/smb.conf
sleep 3


#Create new user for samba network share
echo "You need to create a system user account for your share to use"
echo "..."
sleep 3

read -p "What Should we name your new user account: " NEWUSRNAME

sudo adduser --force-badname $NEWUSRNAME

echo "now we need to create a passord for accessing your network share"
sleep 3

sudo smbpasswd -a


#Set dedicated IP address for yoru raspberry PI
#echo "Do you want to setup your raspberry pi with a dedicated IP address?"
#echo "1 - Yes Please use dedicated IP"
#echo "2 - No Ill do this later"

exit
