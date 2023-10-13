#!/bin/bash

DATABASE_PASSWORD=${1:-Z4bb1xD4t4b4s3}

echo "######################################################################"
echo "                        INSTALACAO DO ZABBIX                          "
echo "                     SISTEMA OPERACIONAL DEBIAN                       "
echo "######################################################################"
echo "                          FONTE DO SCRIPT:                            "
echo "           https://github.com/isaqueprofeta/zabbix-pipe2bash          "
echo "######################################################################"

echo "########################################################"
echo "Instalando DEPENDENCIAS de PACOTES do DEBIAN"
echo "########################################################"
sudo apt-get -q update
sudo apt-get -q -y install gnupg2

echo "########################################################"
echo "BANCO DE DADOS"
echo "########################################################"

echo "########################################################"
echo "BANCO DE DADOS - Instalando Repositório"
echo "########################################################"
sudo echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "########################################################"
echo "BANCO DE DADOS - Instalando Pacotes"
echo "########################################################"
sudo apt-get -q update
sudo apt-get -q -y install postgresql-15

echo "########################################################"
echo "BANCO DE DADOS - Inicializando serviço"
echo "########################################################"
sudo systemctl enable --now postgresql@15-main

echo "########################################################"
echo "BANCO DE DADOS - Configurações gerais"
echo "########################################################"
sudo sed -i "s/ident/md5/g" /etc/postgresql/15/main/pg_hba.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/15/main/postgresql.conf
sudo systemctl restart postgresql@15-main

echo "########################################################"
echo "BANCO DE DADOS - Criação de usuário do Zabbix"
echo "########################################################"
sudo -u postgres psql -c "CREATE USER zabbix WITH ENCRYPTED PASSWORD '$DATABASE_PASSWORD'" 2>/dev/null
sudo -u postgres createdb -O zabbix -E Unicode -T template0 zabbix 2>/dev/null

echo "########################################################"
echo "ZABBIX SERVER"
echo "########################################################"

echo "########################################################"
echo "ZABBIX SERVER - Instalando Repositório"
echo "########################################################"
wget --quiet https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian11_all.deb
sudo dpkg -i zabbix-release_6.0-1+debian11_all.deb

echo "########################################################"
echo "ZABBIX SERVER - Instalando Pacotes"
echo "########################################################"
sudo apt-get -q update
sudo apt-get -q -y install zabbix-server-pgsql zabbix-sql-scripts

echo "########################################################"
echo "ZABBIX SERVER - Configurando schema do banco de dados"
echo "########################################################"
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

echo "########################################################"
echo "ZABBIX SERVER - Configurando o Zabbix Server"
echo "########################################################"
sudo sed -i "s/# DBHost=localhost/DBHost=localhost/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# DBPassword=/DBPassword=$DATABASE_PASSWORD/" /etc/zabbix/zabbix_server.conf

echo "########################################################"
echo "ZABBIX SERVER - Inicializando serviço"
echo "########################################################"
sudo systemctl enable --now zabbix-server

echo "########################################################"
echo "ZABBIX FRONTEND"
echo "########################################################"

echo "########################################################"
echo "ZABBIX FRONTEND - Instalando pacotes"
echo "########################################################"
sudo apt-get -q -y install zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf

echo "########################################################"
echo "ZABBIX FRONTEND - Configurando php"
echo "########################################################"
sed -i "s/php_value\[date.timezone\] = #{PHP_TIMEZONE}/php_value\[date.timezone\] = America\/Sao_Paulo/" /etc/php/7.4/fpm/pool.d/zabbix-php-fpm.conf

echo "########################################################"
echo "ZABBIX FRONTEND - Configurando setup web"
echo "########################################################"
sudo tee /etc/zabbix/web/zabbix.conf.php <<EOL
<?php
    \$DB["TYPE"] = "POSTGRESQL";
    \$DB["SERVER"] = "localhost";
    \$DB["PORT"] = "5432";
    \$DB["DATABASE"] = "zabbix";
    \$DB["USER"] = "zabbix";
    \$DB["PASSWORD"] = "$DATABASE_PASSWORD";
    \$DB["SCHEMA"] = "";
    \$DB["ENCRYPTION"] = false;
    \$DB["KEY_FILE"] = "";
    \$DB["CERT_FILE"] = "";
    \$DB["CA_FILE"] = "";
    \$DB["VERIFY_HOST"] = false;
    \$DB["CIPHER_LIST"] = "";
    \$DB["VAULT_URL"] = "";
    \$DB["VAULT_DB_PATH"] = "";
    \$DB["VAULT_TOKEN"] = "";
    \$DB["DOUBLE_IEEE754"] = true;
    \$ZBX_SERVER = "localhost";
    \$ZBX_SERVER_PORT = "10051";
    \$ZBX_SERVER_NAME = "zabbix";
    \$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOL

echo "###############################################################################"
echo "ZABBIX FRONTEND - Configurando suporte ao português brasileiro e outras linguas"
echo "###############################################################################"

mkdir -p /var/lib/locales/supported.d/
rm -f /var/lib/locales/supported.d/local
cat /usr/share/zabbix/include/locales.inc.php | grep display | grep true | awk '{$1=$1};1' | cut -d"'" -f 2 | sort | xargs -I '{}' bash -c 'echo "{}.UTF-8 UTF-8"' >> /etc/locale.gen
dpkg-reconfigure --frontend noninteractive locales

echo "###############################################################################"
echo "ZABBIX FRONTEND - Configurando nginx para o zabbix na raiz do site, na porta 80"
echo "###############################################################################"
sudo sed -i "s/#        listen          8080;/        listen 80 default_server;\\n        listen [::]:80 default_server;/" /etc/zabbix/nginx.conf
sudo sed -i "s/#        server_name     example.com;/        server_name _;/" /etc/zabbix/nginx.conf
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/conf.d/zabbix.conf
sudo ln -s /etc/zabbix/nginx.conf /etc/nginx/sites-available/default
sudo ln -s /etc/zabbix/nginx.conf /etc/nginx/sites-enabled/default

echo "#######################################"
echo "ZABBIX FRONTEND - Inicializando Serviço"
echo "#######################################"
systemctl enable --now php7.4-fpm
sleep 5
systemctl enable --now nginx
sleep 5
systemctl stop php7.4-fpm
systemctl stop nginx
sleep 5
systemctl start php7.4-fpm
sleep 5
systemctl start nginx

echo "#######################################"
echo "ZABBIX AGENT"
echo "#######################################"

echo "####################################################"
echo "ZABBIX AGENT - Instalação para monitoração do SERVER"
echo "####################################################"
sudo apt-get -q -y install zabbix-agent

echo "####################################################"
echo "ZABBIX AGENT - Inicializando o Serviço"
echo "####################################################"
systemctl enable --now zabbix-agent

echo "####################################################"
echo "TIMESCALEDB"
echo "####################################################"

echo "####################################################"
echo "TIMESCALEDB - Instalando repositorios"
echo "####################################################"
sudo echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/timescaledb.list
wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -

echo "####################################################"
echo "TIMESCALEDB - Instalando pacotes"
echo "####################################################"
sudo apt-get -q update
sudo apt-get -q -y install timescaledb-2-postgresql-15='2.10.3~debian11' timescaledb-2-loader-postgresql-15='2.10.3~debian11'

echo "####################################################"
echo "TIMESCALEDB - Parando Zabbix Server"
echo "####################################################"
systemctl stop zabbix-server

echo "####################################################"
echo "TIMESCALEDB - Configurações do postgresql"
echo "####################################################"
echo "shared_preload_libraries = 'timescaledb'" >> /etc/postgresql/15/main/postgresql.conf
sudo sed -i "s/max_connections = 20/max_connections = 50/" /etc/postgresql/15/main/postgresql.conf
echo "timescaledb.license=timescale" >> /etc/postgresql/15/main/postgresql.conf

echo "#####################################################"
echo "TIMESCALEDB - Inicializando e configurando postgresql"
echo "#####################################################"
sudo systemctl restart postgresql@15-main
sudo -u postgres timescaledb-tune --quiet --yes
echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" | sudo -u postgres psql zabbix 2>/dev/null

echo "########################################################"
echo "TIMESCALEDB - Migrando schema do zabbix para timescaledb"
echo "########################################################"
cat /usr/share/zabbix-sql-scripts/postgresql/timescaledb.sql | sudo -u zabbix psql zabbix

echo "########################################################"
echo "TIMESCALEDB - Inicializando sistema migrado"
echo "########################################################"
systemctl start zabbix-server
sleep 5
systemctl restart php7.4-fpm
sleep 5
systemctl restart nginx

echo "########################################################"
echo "ZABBIX instalado com timescaledb e nginx"
echo "########################################################"

echo "########################################################"
echo "Acesse o IP deste servidor no browser com http"
echo "########################################################"
