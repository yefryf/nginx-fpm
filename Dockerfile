FROM       ubuntu:14.04
MAINTAINER Yefry Figueroa

# Set to no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y software-properties-common && \
    nginx=stable && \
    add-apt-repository ppa:nginx/$nginx && \
    apt-get update && \
    BUILD_PACKAGES="supervisor nginx php5-fpm git php5-mysql php5-curl php5-gd php5-intl php5-mcrypt php5-memcache php5-sqlite php5-xmlrpc php5-xsl pwgen" && \
    apt-get -y install $BUILD_PACKAGES && \
    apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && apt-get clean && apt-get autoclean

# OpenSSH
RUN apt-get install -y openssh-server vim

RUN echo 'root:toor' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# Needed dirs
RUN mkdir /var/run/sshd && \
    mkdir /var/run/supervisor && \
    mkdir -p /var/log/supervisor

ADD nginx-vhost.conf /etc/nginx/sites-available/default
ADD index.php /var/www/html/index.php

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80

CMD ["/usr/bin/supervisord"]
