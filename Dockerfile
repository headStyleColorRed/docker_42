# Getting base image as Debian

FROM debian:buster

# UPDATE
RUN apt-get update
RUN apt-get upgrade -y


# ---------------	I N S T A L L S  -------------- #
RUN apt-get install nginx -y
RUN apt-get install -y wget
RUN apt-get install -y php7.3 php-mysql php-fpm php-cli php-mbstring
RUN apt-get install -y mariadb-server

# ---------------	G N I N X  -------------- #
# We delete the original default files and add and
# copy our nginx configuration to the sites-available (linked after with sites-enabled)

RUN	rm -f /etc/nginx/sites-available/default
RUN	rm -f /etc/nginx/nginx.conf

COPY srcs/nginx/localhost.conf /etc/nginx/sites-available/
COPY srcs/nginx/nginx.conf /etc/nginx/

RUN ln -s /etc/nginx/sites-available/localhost.conf /etc/nginx/sites-enabled/localhost.conf


# -----------		P  H  P  	----------- #
# WORKDIR	/etc/php/7.0/fpm/pool.d




# -----------	W O R D P R E S S ----------- #

WORKDIR	/var/www/html

COPY srcs/index.html .


# RUN		wget https://wordpress.org/latest.tar.gz

# RUN		tar -xf latest.tar.gz && rm -f latest.tar.gz


EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

