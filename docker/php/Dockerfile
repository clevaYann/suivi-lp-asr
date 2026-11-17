# Image de développement qui reproduit Lakartxela : Apache + PHP 8.5.
# Utilisée uniquement en local : la recette et la production tournent
# directement sur Lakartxela, sans Docker.
FROM php:8.5-apache

# Extensions PHP : MySQL (pdo_mysql), Laravel (mbstring, bcmath, intl),
# Laravel Excel / PhpSpreadsheet (zip, gd).
COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql mbstring bcmath intl zip gd

# Outils : git et unzip pour Composer, Doxygen pour la documentation du code.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip doxygen \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configuration PHP de développement + réglages du projet (imports eLearn).
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY php.ini "$PHP_INI_DIR/conf.d/zz-suivi-lp-asr.ini"

# Apache sert le dossier public/ de Laravel, avec la réécriture d'URL (.htaccess).
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && a2enmod rewrite headers

WORKDIR /var/www/html
