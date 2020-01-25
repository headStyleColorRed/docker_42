# Getting base image as Debian

FROM debian:buster

# UPDATE
RUN apt-get update
RUN apt-get upgrade -y

WORKDIR	/var/www/html

# Install nginx wget & php
RUN apt-get install -y nginx wget php-fpm

# ---------------	G N I N X  -------------- #
# We copy nginx configuration to the gninx folders
# and delete the original one.
#COPY	srcs/default.conf /etc/nginx/sites-enabled/

#RUN		rm -f /etc/nginx/sites-enabled/default


# -----------	W O R D P R E S S ----------- #
RUN		wget https://wordpress.org/latest.tar.gz

RUN		tar -xf latest.tar.gz && rm -f latest.tar.gz


CMD ["nginx", "-g", "daemon off;"] 