FROM ubuntu:trusty
MAINTAINER Lumachan <luma@luma.fr>

RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty multiverse" > /etc/apt/sources.list.d/multiverse.list
RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list.d/multiverse.list
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list.d/multiverse.list
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
	apache2 \
        libapache2-mod-php5 \
	libttspico0 \
	libttspico-utils \
	libttspico-dev \
	libttspico-data \
	lame \
	curl \
	git

RUN rm -rf /var/lib/apt/lists/*

# Enable apache mods.
RUN a2enmod php5

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/tts
ADD tts.php /var/www/tts/
ADD composer.json /var/www/tts/

RUN composer install

EXPOSE 80
CMD /usr/sbin/apache2ctl -D FOREGROUND
