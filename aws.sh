#!/bin/bash

echo "Creator: Elliott Ning - Oracle Cloud Specialist Consultant"
echo "Version: 1.01"
echo "Date: 11/13/2017"

#Step0: Check provisioned resource
echo -e "Please make sure all needed resource is provisioned, and type y to continue:"
read input
echo "Starting script"

echo "Update OS"
yum update -y

echo "Install software for webserver"
yum install httpd -y

echo "Enable firewall to have these ports 80 / 443 added; start and enable webserver"
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
systemctl start httpd
systemctl enable httpd

echo "Install software for PHP"
yes | yum install php php-mysql php-pdo php-gd php-xml –y
systemctl restart httpd.service

echo "Enable MySQL repo and install software for MySQL-server"
yes | yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yes | yum install mysql-community-server

echo "Start and enable mysqld"
systemctl start mysqld
systemctl enable mysqld

echo "Get the latest tar ball from wordpress.org and untar the package"
cd /var/www/html/
wget http://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz
chown -R apache:apache /var/www/html/*

echo "Step 2: Create MySQL Database and configure WordPress"
echo "Configure MySQL database"
#mysql_secure_installation
echo "Resetting MySQL root password"
mysql -e "UPDATE mysql.user SET Password = PASSWORD('password') WHERE User = 'root'"
echo "Removing MySQL anonymous users"
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
echo "Removing MySQL test database"
mysql -e "DROP DATABASE test"
echo "Take effect of configurations"
mysql -e "FLUSH PRIVILEGES"

echo "Create Database for WordPress"
mysql -uroot -ppassword -e "CREATE DATABASE wordpress"
echo "Create User wordpressuser for Database WordPress"
mysql -uroot -ppassword -e "CREATE USER wordpressuser@localhost IDENTIFIED BY 'password'"
echo "Grant privileges to User wordpressuser"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'password'"
echo "Take effect of creations"
mysql -uroot -ppassword -e "FLUSH PRIVILEGES"
echo "Database wordpress User wordpressuser has been created"

echo "Configure WordPress to use the MySQL database"
cp wordpress/wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/g' wp-config.php
sed -i 's/username_here/wordpressuser/g' wp-config.php
sed -i 's/password_here/password/g' wp-config.php

echo "Enter the URL below in your browser to complete the workshop:"
IP=`wget http://ipecho.net/plain -O - -q ; echo`
echo "http://$IP/wordpress/wp-admin/install.php"

#EOF
