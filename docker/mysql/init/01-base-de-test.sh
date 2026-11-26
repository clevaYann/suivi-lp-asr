#!/bin/sh
# Exécuté une seule fois, à la création du volume MySQL.
# Crée la base utilisée par les tests (voir phpunit.xml) et donne les droits
# à l'utilisateur de l'application.
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
CREATE DATABASE IF NOT EXISTS suivi_lp_asr_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON suivi_lp_asr_test.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
SQL
