#!/bin/bash

#packages to be installed from the lamp stack
packages=$1
#additional packages
addpac=$2
#the logfile
logfile="/var/log/wp_install.log"


#validate the parameters
function valPar {
#install apache?
if [[ $packages == *"a"* ]]
then
	ia=true
else
	ia=false
fi

#install mysql?
if [[ $packages == *"m"* ]]
then
	im=true
else
	im=false
fi

install php?
if [[ $packages == *"p"* ]]
then
	ip=true
else
	ip=false
fi

#install phpmyadmin?
if [[ $addpac == *"p"* ]]
then
	iph=true
else
	iph=false
fi

#install wp-cli?
if [[ $addpac == *"w"* ]]
then
	wpcli=true
else
	wpcli=false
fi

}

#does the parameters has a value?
function chkempt {

if [ -z "$packages" ];
then
	echo "Are you sure that you don't want to install any package of lamp? [Y/n]: "
	read insans
	#if no packages need to be installed
	if [[ -z "$insans" ]] || [[ $insans == "y" ]] || [[ $insans == "Y" ]]; then
		return
	#if user wants to install packages	
	elif [[ $insans == "n" ]] || [[ $insans == "N" ]]; then
		echo "Please provide the packages you want to install."
		 
		read -p  "Aviable are: (a)pache2,(m)ysql-server(p)hp5 " packages
		echo "\n"
		valPar
	#if user is to stupid to write a usefull information 	
	else
		chkempt
		wl "User is stupid"
		return
	fi
	
fi
	
	
	
}
#see title
function getDate {
	
	#format date and safe to value
	DATE=`date +%Y-%m-%d:%H:%M:%S`
	
}

#(w)rite (l)og
function wl {
	#get date
	getDate
	#first parameter is the message
	message=$1
	#write message to log
	echo "[ $DATE ] $message">> $logfile
	
	
}

#Install the packages
function installpacs {
	#update the sources
	wl "Update sources"
	apt-get update
	#install the packages defined in ValPar
	if [[ $ia == true ]]
	then
		wl "installing apache2"
		apt-get install apache2
		wl "installed apache2"
	fi
	
	if [[ $im == true ]]
	then
		wl "installing mysql-server"
		apt-get install mysql-server
		wl "installed mysql-server"
	fi
	
	if [[ $ip == true ]]
	then
		wl "installing php5"
		apt-get install php5
		apt-get install php5-gd libssh2-php php5-mysql
		wl "installed php5"
	fi
	
	if [[ $iph == true ]]
	then
		wl "installing phpmyadmin"
		apt-get install phpmyadmin
		wl "installed phpmyadmin"
	fi
	

	if [[ $wpcli == true ]]
	then
		wl "installing wp-cli"
		wl "downloading wp-cli"
		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
 		wl "make wp-cli executable"
		chmod +x wp-cli.phar
		wl "move wp-cli"
		mv wp.phar /bin/wp
		wl "installed wp-cli"
	fi
	
	





	
}

#download WP
function loadWP {
	#latest.tar.gz is ALWAYS the latest wp version
	wl "downloading WordPress...."
	wget http://wordpress.org/latest.tar.gz
	wl "Wordpress downloaded"
	#unpack it
	wl "unpack wp"	
	tar -xzvf latest.tar.gz 
	wl "wp unpacked"
	
}

#for creating the db
function createSQLFile {
	
	#ask for a new password for the db service user
	read -s -p  "Type a password for the db user: `echo $'\n> '`" sqlpass
	#repeat the password
	read -s -p "Retype the password `echo $'\n> '`" sqlpass1
	#passwords are the same?
	if [[ $sqlpass != $sqlpass1 ]]; then
		createSQLFile
		wl "Password validate error"
		return
	fi
	
	#create cmmand file
	touch commands.sql
	##Write commands to file
	#crate database wordpress
	echo "CREATE DATABASE wordpress;" >> commands.sql
	#create the service user
	echo "CREATE USER wp_user@localhost IDENTIFIED BY '"$sqlpass"';" >> commands.sql
	#grant all privileges on the db and its tables for the user
	echo "GRANT ALL PRIVILEGES ON wordpress.* TO wp_user@localhost;" >> commands.sql
	#reload privileges
	echo "FLUSH PRIVILEGES;" >> commands.sql
	wl "created command file for mysql"
	
}

#crate the db
function createDB {
	
	#ask for the root password
	read -s -p "Please type your root mysql password here: `echo $'\n> '`" sqlrootpass
	#log in to mysql with root and the password, execute all commands in the file
	wl "create database..."	
	mysql -u root -p$sqlrootpass < commands.sql 
	wl "database created"
	wl "service user created"
	wl "privileges updated"


}

#configure wp
function WPconf {
	#go to its directory
	cd wordpress
	#create wp config file from sample config
	cp wp-config-sample.php wp-config.php
	wl "WP config file created"
	#repleace values with actual db name, username and password for mysql
	wl "Updating WP-Config file....."	
	sed -i 's/database_name_here/wordpress/g' wp-config.php
	sed -i 's/username_here/wp_user/g' wp-config.php
	sed -i "s/password_here/$sqlpass/g" wp-config.php
	wl "wpconifg updated"
	#go back to working directory
	cd ..
}
#upload wp to www root
function uploadWP {
	#create www user
	wl "adding service user"
	useradd wp_user
	wl "service user added"
	#sync working dir with www root
	wl "Uploading wp....."
	rsync -avP wordpress/ /var/www/html
	wl "Wordpress uploaded to www root"
	#go to www root
	cd /var/www/html
	#change owner to www user and www group
	wl "Updating premissions and owner"
	chown -R wp_user:www-data *
	#change writes for the files in www root
	chmod g+w /var/www/html -R
	#make uploadfile
	mkdir /var/www/html/wp-content/uploads
	wl "upload folder created"
	chown -R :www-data /var/www/html/wp-content/uploads
	wl "premissions and owner changed"
	#make backup copy from apache2 default index file ("It works!")
	mv index.html index.html.bak
	wl "removed default apache2 index.html"
	
}
#make working dir
wl "creating working dir"
mkdir /tmp/wp_install
wl "working dir created"
#go to working dir
cd /tmp/wp_install
wl "validating parameters...."
valPar
wl "checking parameters...."
chkempt
wl "installing packages"
installpacs
wl "loading WordPress"
loadWP
wl "creating mysql Commands"
createSQLFile
wl "Execute mysql commands"
createDB
wl "configure wordpress"
WPconf
wl "upload wp to wwwroot"
uploadWP
wl "removing working dir"
rm -rf /tmp/wp_install
wl "working dir removed"
