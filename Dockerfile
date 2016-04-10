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
# Enviroment
###
# Main
#ENV PHABRICATOR_BASEURI="http://localhost/"
ENV PHABRICATOR_STORAGE_LOCAL_DISK_PATH="/var/www/files"
ENV PHABRICATOR_REPO_LOCAL_DISK_PATH="/var/repo"

# Database
ENV PHABRICATOR_DB_HOST=localhost
ENV PHABRICATOR_DB_PORT=3306
ENV PHABRICATOR_DB_USER=root
ENV PHABRICATOR_DB_PASS=""

###
# Volimes
#
# Usage:
#   -v /etc/phabricator:/var/www/phabricator/conf
#   -v /var/phabricator:/var/www/files
#   -v /var/repo:/var/repo
###
#VOLUME /var/www/libphutil
#VOLUME /var/www/arcanist
VOLUME /var/www/phabricator

# Local files
RUN mkdir -p /var/www/files
VOLUME /var/www/files

# Repo dir
RUN mkdir -p /var/repo/
VOLUME /var/repo

###
# Install Phabricator
###
RUN git clone git://github.com/facebook/libphutil.git /usr/src/phabricator/libphutil \
    && git clone git://github.com/facebook/arcanist.git /usr/src/phabricator/arcanist \
    && git clone git://github.com/facebook/phabricator.git /usr/src/phabricator/phabricator

###
# Expose ports
###
EXPOSE 9000
EXPOSE 22

###
# Entry point
###
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
