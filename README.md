# wp_installer.sh
This was a project for school. It also was one of the first scripts, that I wrote, that actually make sense and I can use it in production. This bash script will download and install packages from the lamp stack (+phpmyadmin). After that it creates the mysql DB and installs and configure  WordPress.

#Requirements

The bash script is currently written for ubuntu (because this was used for school). So the www root is at /var/www/html.
You also need:
  apt:  installing the lamp stack
  wget: downloading WordPress

#Tip

```
mv wp-install.sh /bin/wp-install
```

Then you can easy type wp-install in the terminal from every directory, to run the script


#Usage

##Syntax
```
sudo wp-install <packages> <additional_packages>
```
##Explenation

If you want to install the full lamp stack (apache2, mysql-server and php5) and phpmyadmin type the following:
```
sudo wp-install lamp p
```
Actually you can littery type anything. but it checks for a a,m and p in the first parameter and a p in the second parameter.

If you don't want to install any packages just type nothing and confirm the question that you really don't want to install anything.

#Not perfect

This script isn't perfect. It was written in a school project with limited time. So three big things are missing: support for other distros (apt, www root), error handling, and a logfile based on that error handling. But this things are on my to do list.
