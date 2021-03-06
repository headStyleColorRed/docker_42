# Getting base image as Debian

FROM 	debian:buster

# U P D A T E
RUN		apt-get update
RUN		apt-get upgrade -y


# ---------------	I N S T A L L S  -------------- #
RUN		apt-get install nginx -y
RUN		apt-get install -y wget
RUN		apt-get install -y php-fpm php-mysql
RUN		apt-get install -y mariadb-server
RUN		apt-get install -y vim


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

# ---------------	M A R I A  -------------- #
RUN service mysql start  && \
echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password && \
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password && \
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password && \
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password 



# -----------	P H P 	M Y  A D M I N	----------- #
RUN		wget https://files.phpmyadmin.net/phpMyAdmin/5.0.0-rc1/phpMyAdmin-5.0.0-rc1-all-languages.tar.gz
RUN 	tar xf phpMyAdmin-5.0.0-rc1-all-languages.tar.gz && rm -rf phpMyAdmin-5.0.0-rc1-all-languages.tar.gz
RUN 	mv phpMyAdmin-5.0.0-rc1-all-languages phpmyadmin
COPY 	./srcs/config.inc.php phpmyadmin


# ---------------	S S L   C E R T  -------------- #
# https://github.com/FiloSottile/mkcert
# https://kifarunix.com/how-to-create-self-signed-ssl-certificate-with-mkcert-on-ubuntu-18-04/
RUN mkdir ~/mkcert &&\
	cd ~/mkcert &&\
	wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 &&\
	mv mkcert-v1.4.1-linux-amd64 mkcert &&\
  	chmod +x mkcert &&\
	./mkcert -install && ./mkcert localhost


# P O R T S
EXPOSE 80 443


# C O N T A I N E R    L A U N C H 
CMD service nginx start && \
	service mysql start && \
	service php7.3-fpm start && \
	sleep infinity