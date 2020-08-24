# Getting base image as Debian

FROM 	debian:buster

# UPDATE
RUN		apt-get update
RUN		apt-get upgrade -y


WORKDIR	/var/www/html/

# ---------------	I N S T A L L S  -------------- #
RUN		apt-get install nginx -y
RUN		apt-get install -y wget
RUN		apt-get install -y php7.3 php-mysql php-fpm php-cli php-mbstring
RUN		apt-get install -y mariadb-server
RUN		apt-get install -y vim


# -----------	W O R D P R E S S ----------- #
# First we download wordpress and unzip it.
# Then take our configuration and substitute the original one

RUN			wget https://wordpress.org/latest.tar.gz
RUN			tar -xf latest.tar.gz && rm -f latest.tar.gz

COPY		srcs/wp-config.php wordpress/



# -----------	P H P 	M Y  A D M I N	----------- #

RUN		wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-all-languages.tar.xz

RUN		tar xf phpMyAdmin-4.9.2-all-languages.tar.xz 
RUN		rm -f phpMyAdmin-4.9.2-all-languages.tar.xz
RUN		mv phpMyAdmin-4.9.2-all-languages phpMyAdmin


# ---------------	M A R I A  -------------- #

RUN		service mysql start && \
		mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('toor');" && \
		mysql -e "CREATE DATABASE db"


# ---------------	G N I N X  -------------- #
# We delete the original default files and add and
# copy our nginx configuration to the sites-available (linked after with sites-enabled)

RUN		rm -f /etc/nginx/sites-enabled/default
RUN		rm -f /etc/nginx/nginx.conf

COPY	srcs/mywebsite.conf /etc/nginx/sites-available/
COPY	srcs/nginx.conf /etc/nginx/

RUN		ln -s /etc/nginx/sites-available/mywebsite.conf /etc/nginx/sites-enabled/mywebsite.conf


# ---------------	S S L   C E R T  -------------- #
# https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html
# https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm
# 1. Number of bits for the generated rsa key
# 2. Outputs a self signed certificate instead of a certificate request
# 3. Signing the request with a sha... encryption
# 4. Avoiding password
# 5. Specifies the output filename to write to or standard output by default.
# 6. Gives the filename to write the newly created private key
# 7. Sets subject name for new request or supersedes the subject name when processing a request, each /.../ means ==>
	# "	Country Name  /  State or Province Name  /  Locality Name 	/  Organization Name  /  Organizational Unit Name / Common Name "


RUN		mkdir /etc/nginx/ssl
##							___*1___  __*2__   ___*3___   ___4___   _________________*5________________    __________________*6__________________   		_________________*7_______________   
RUN		openssl req -newkey rsa:4096  -x509    -sha256    -nodes   -days 365 -out /etc/nginx/ssl/mycertificate.pem  -keyout /etc/nginx/ssl/mycertificate.key -subj "/C=ES/ST=Madrid/L=Madrid/O=42 School/OU=rlabrado/CN=localhost"


# RUN service php7.3-fpm start 
RUN service mysql start

EXPOSE 80 443


CMD ["nginx", "-g", "daemon off;"]

