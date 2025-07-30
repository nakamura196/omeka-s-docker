FROM php:8.1-apache
LABEL maintainer="Omeka S Docker <noreply@example.com>"

# Enable Apache modules
RUN a2enmod rewrite headers

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get -qq update && apt-get -qq -y upgrade && \
    apt-get install -y \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    imagemagick \
    libmagickwand-dev \
    unzip \
    wget \
    git \
    ssmtp \
    gettext-base

# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd intl xml zip opcache && \
    pecl install imagick && \
    docker-php-ext-enable imagick

# Configure ssmtp
RUN echo "root=noreply@localhost" > /etc/ssmtp/ssmtp.conf && \
    echo "mailhub=mailpit:1025" >> /etc/ssmtp/ssmtp.conf && \
    echo "hostname=localhost" >> /etc/ssmtp/ssmtp.conf && \
    echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && \
    echo "UseTLS=NO" >> /etc/ssmtp/ssmtp.conf && \
    echo "UseSTARTTLS=NO" >> /etc/ssmtp/ssmtp.conf

# Create PHP configuration template
RUN echo 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED' > /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'display_errors = On' >> /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'log_errors = On' >> /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'memory_limit = ${PHP_MEMORY_LIMIT:-256M}' >> /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE:-100M}' >> /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'post_max_size = ${PHP_POST_MAX_SIZE:-100M}' >> /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'max_execution_time = 300' >> /usr/local/etc/php/conf.d/custom.ini.template && \
    echo 'sendmail_path = /usr/sbin/ssmtp -t' >> /usr/local/etc/php/conf.d/custom.ini.template

# Download Omeka-s
ARG OMEKA_VERSION=4.1.1
RUN wget https://github.com/omeka/omeka-s/releases/download/v${OMEKA_VERSION}/omeka-s-${OMEKA_VERSION}.zip -O /var/www/omeka-s.zip && \
    unzip -q /var/www/omeka-s.zip -d /var/www/ && \
    rm /var/www/omeka-s.zip && \
    rm -rf /var/www/html/ && \
    mv /var/www/omeka-s/ /var/www/html/

COPY ./.htaccess /var/www/html/.htaccess

# Configure volumes and permissions
COPY ./database.ini /var/www/html/volume/config/
RUN mkdir -p /var/www/html/volume/files/ && \
    mkdir -p /var/www/html/modules && \
    mkdir -p /var/www/html/themes && \
    rm /var/www/html/config/database.ini && \
    ln -s /var/www/html/volume/config/database.ini /var/www/html/config/database.ini && \
    rm -Rf /var/www/html/files/ && \
    ln -s /var/www/html/volume/files/ /var/www/html/files && \
    chown -R www-data:www-data /var/www/html/ && \
    chmod -R 755 /var/www/html/modules /var/www/html/themes && \
    find /var/www/html/volume/ -type f -exec chmod 600 {} \;

# Create entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME /var/www/html/volume/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]