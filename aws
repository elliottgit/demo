#!/bin/bash
#title           :aws.sh
#description     :Bash script for AWS work sample.
#author		       :Elliott Ning
#date            :20171114
#version         :1.4

#==============================================================================

# set variables
export blockdevice=
export blockuuid=UUID=

#==============================================================================

# display variables
echo "EBS Device name is $blockdevice"
echo "EBS Device uuid is $blockuuid"

echo -e "Check the EBS volume variables and type y to start the script:"
read input
if [ $input == 'y' ]
then
  echo "Mount EBS volume."
  mkfs -t ext4 $blockdevice
  mkdir /ebsvolume
  mount $blockdevice /ebsvolume

  echo "Mount volume on every system reboot"
  sudo cp /etc/fstab /etc/fstab.orig
  sed -i -e '$blockuuid /ebsvolume ext4 defaults,nofail 0 2' /etc/fstab
  cd /ebsvolume

  echo "Update system..."
  #yum -y update
  yum -y install yum-utils

  echo "Install software for webserver."
  yum -y install httpd

  echo "Enable firewall to have ports 80 / 443 opened; start and enable webserver."
  firewall-cmd --permanent --add-port=80/tcp
  firewall-cmd --permanent --add-port=443/tcp
  firewall-cmd --reload
    
  echo "Start and enable webserver."
  systemctl start httpd
  systemctl enable httpd


  echo "download content"
  cd /var/www/html/
  wget https://raw.githubusercontent.com/elliottgit/demo/master/index.html
  chown -R apache:apache /var/www/html/*

  echo "Enter the URL below in your browser to see the website:"
  IP=`wget http://ipecho.net/plain -O - -q ; echo`
  echo "http://$IP"

else
  echo "Edit the variables and try again"

fi

#EOF
