FROM php:7.1.5-fpm
MAINTAINER Luca Santarella <luca.santarella@gmail.com>

# Install MySql PDO
RUN docker-php-ext-install pdo pdo_mysql

ENV PHALCON_VERSION=3.3.2

WORKDIR /var/tmp

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer

# Install Source Dependancies
RUN apt-get -y update && apt-get -y install \
	git \
	unzip

# Compile Phalcon
RUN set -xe && \
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf v${PHALCON_VERSION}.tar.gz && cd cphalcon-${PHALCON_VERSION}/build && ./install && \
        echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini && \
        cd ../.. && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION}

# Compile Timecop
RUN git clone https://github.com/hnw/php-timecop.git && \
	cd php-timecop && \
	phpize && \
	./configure && \
	make && \
	make install && \
	echo "extension=timecop.so" > /usr/local/etc/php/conf.d/timecop.ini && \
        cd ../ && rm -rf php-timecop*

# Install XDEBUG
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /
