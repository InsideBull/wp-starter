FROM php:7.0-apache

LABEL description="Apache & PHP7.0 image for wordpress app with ssmtp."

# install the PHP extensions we need
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y \
        openssl \
        libmcrypt-dev \
        libjpeg-dev \
        libpng-dev \
        ssmtp \
        mailutils \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install gd mysqli pdo pdo_mysql opcache mcrypt gettext

RUN apt-get install -y zlib1g-dev; \
 rm -rf /var/lib/apt/lists/* ; \
 docker-php-ext-install zip

# set up sendmail config, see http://linux.die.net/man/5/ssmtp.conf for options
RUN echo "hostname=localhost.localdomain" > /etc/ssmtp/ssmtp.conf
RUN echo "root=h.rakotonjanahary@gmail.com" >> /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=maildev" >> /etc/ssmtp/ssmtp.conf
# The above 'maildev' is the name you used for the link command
# in your docker-compose file or docker link command.
# Docker automatically adds that name in the hosts file
# of the container you're linking MailDev to.

# Set up php sendmail config
RUN echo "sendmail_path=sendmail -i -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini

# Fully qualified domain name configuration for sendmail on localhost.
# Without this sendmail will not work.
# This must match the value for 'hostname' field that you set in ssmtp.conf.
RUN echo "localhost localhost.localdomain" >> /etc/hosts

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# enable apache module
RUN a2enmod headers rewrite expires

# Register volume
VOLUME /var/www/html

# apache2 foreground
CMD ["apache2-foreground"]
