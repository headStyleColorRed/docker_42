# Getting base image as Debian

FROM 	debian:buster

# UPDATE
RUN		apt-get update
RUN		apt-get upgrade -y


# ---------------	I N S T A L L S  -------------- #
RUN		apt-get install nginx -y
RUN		apt-get install -y wget
RUN		apt-get install -y php-fpm php-mysql
RUN		apt-get install -y mariadb-server
RUN		apt-get install -y vim

#SLL SETUP
RUN mkdir ~/mkcert &&\
	cd ~/mkcert &&\
	wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 &&\
	mv mkcert-v1.4.1-linux-amd64 mkcert &&\
  	chmod +x mkcert &&\
	./mkcert -install && ./mkcert localhost


# ---------------	G N I N X  -------------- #
# We delete the original default files and add and
# copy our nginx configuration to the sites-available (linked after with sites-enabled)
COPY srcs/mywebsite.conf /etc/nginx/sites-available/mywebsite.conf

RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/mywebsite.conf /etc/nginx/sites-enabled/mywebsite.conf


# -----------	W O R D P R E S S ----------- #
# First we download wordpress and unzip it.
# Then take our configuration and substitute the original one
WORKDIR	/var/www/html/

RUN			wget https://wordpress.org/latest.tar.gz
RUN			tar -xf latest.tar.gz && rm -f latest.tar.gz
RUN 		cp -r wordpress/* . && rm -rf wordpress 

COPY		srcs/wp-config.php .


#DATABASE SETUP
RUN service mysql start && \
	echo "CREATE DATABASE wordpress; \
	GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';\
	FLUSH PRIVILEGES;update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root

#PHPMYADMIN INSTALL
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.0-rc1/phpMyAdmin-5.0.0-rc1-all-languages.tar.gz && \
	mkdir /var/www/html/phpmyadmin && \
	tar xzf phpMyAdmin-5.0.0-rc1-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin && \
	rm phpMyAdmin-5.0.0-rc1-all-languages.tar.gz
COPY srcs/config.inc.php /var/www/html/phpmyadmin/

#ALLOW NGINX USER
RUN chown -R www-data:www-data /var/www/* && \
	chmod -R 755 /var/www/*

# Open port 80 and 443
EXPOSE 80 443

# Execute when container starts
CMD service nginx start && \
	service mysql start && \
	service php7.3-fpm start && \
	sleep infinity