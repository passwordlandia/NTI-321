yum -y install cacti               # Installes a number of packages, including mariadb, httpd, php and so on
yum install mariadb-server         # The mysql/mariadb client installs with the cacti stack but not the server
                                   # If you want to have multiple cacti nodes, considder using the client and connecting
                                   # to another server
                                   
yum install php-process php-gd php mod_php
                                   
                    
systemctl enable mariadb           # Enable db, apache and snmp (not cacti yet)
systemctl enable httpd
systemctl enable snmpd


systemctl start mariadb           # Start db, apache and snmp (not cacti yet)
systemctl start httpd
systemctl start snmpd

mysqladmin -u root password ***                                     # Set your mysql/mariadb pasword.  here *** is your password
                                                                    # Make a sql script to create a cacti db and grant the cacti user access to it

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql    # Transfer your local timezone info to mysql

echo "create database cacti;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'cactipass';  # Set this to somthing better than 'cactipass'
FLUSH privileges;

GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;            # Added to fix a timezone issue
flush privileges;" > stuff.sql


mysql -u root  -p < stuff.sql    # Run your sql script
rpm -ql cacti|grep cacti.sql     # Will list the location of the package cacti sql script
                                 # In this case, the output is /usr/share/doc/cacti-1.0.4/cacti.sql, run that to populate your db
mysql cacti < /usr/share/doc/cacti-1.1.37/cacti.sql -u cacti -p  
  
mysql -u cacti -p cacti < /usr/share/doc/cacti-1.0.4/cacti.sql
vim /etc/cacti/db.php            # Set database username and password in $database_username = ''; and $database_password = '';


/etc/httpd/conf.d/cacti.conf     # Top open up access from your subnet, external host or anywere.  Note, anywere isn't recommended
                                 # If you go that route, make a security pass when you're done and tighten it down.

systemctl restart httpd.service
sed -i 's/#//g' /etc/cron.d/cacti
setenforce 0




End scripty part.  Further bug fixes, you'll need to update your php.ini like so:


[root@cacti-c etc]# diff php.ini php.ini.orig 
878c878
< date.timezone = America/Regina
---
> ;date.timezone =




