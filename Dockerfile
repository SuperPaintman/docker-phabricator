FROM php:5.5.34-fpm
#FROM php:7.0.5-fpm

MAINTAINER SuperPaintman <SuperPaintmanDeveloper@gmail.com>

###
# Install dependencies
###
RUN apt-get update && apt-get install -y git python-pygments

###
# Install extensions
# 
# Required:
#   * mbstring
#   * iconv
#   * mysqli
#   * curl
#   * pcntl
#   * gd
#   * apc
#  
# Optional:
#   * opcache
#   * zip
#   * json
###
RUN apt-get update && apt-get install -y libcurl4-gnutls-dev libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install mbstring iconv mysqli curl pcntl gd opcache zip json
#    && pecl install apc \
#    && docker-php-ext-enable apc

###
# PHP settings
###
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/phabricator

###
# Install Phabricator
###
RUN git clone git://github.com/facebook/libphutil.git /var/www/libphutil \
    && git clone git://github.com/facebook/arcanist.git /var/www/arcanist \
    && git clone git://github.com/facebook/phabricator.git /var/www/phabricator

###
# Expose ports
###
EXPOSE 9000
EXPOSE 22

###
# Create repo dir
###
RUN mkdir -p /var/repo/
VOLUME /var/repo

###
# Enviroment
###
# Main
#ENV PHABRICATOR_BASEURI="http://localhost/"

# Database
ENV PHABRICATOR_DB_HOST=localhost
ENV PHABRICATOR_DB_PORT=3306
ENV PHABRICATOR_DB_USER=root
ENV PHABRICATOR_DB_PASS=""

###
# Entry point
###
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
