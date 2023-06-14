# zabbix-pipe2bash

Pipe to bash install scripts ([Be carefull about it](https://0x46.net/thoughts/2019/04/27/piping-curl-to-shell/))

Zabbix 6.0 + PostgreSQL 15 + Timescaledb + Nginx 

en_US: Complete Zabbix in less than 5 minutes remember to change database password "Z4bb1xD4t4b4s3" and use a clean OS to ensure it to work.

pt_BR: Zabbix completo em menos de 5 minutos, lembre de mudar a senha do banco de dados "Z4bb1xD4t4b4s3" e use uma instalação nova do SO para garantir que funcione.

- Debian 11:

```sh
apt update; apt install -y curl; curl -sSL https://raw.githubusercontent.com/isaqueprofeta/zabbix-pipe2bash/main/zbx60_bullseye_pgtdb_nginx.sh | bash -s Z4bb1xD4t4b4s3
```

- RHEL, Rocky, Alma 8:

```sh
curl -sSL https://raw.githubusercontent.com/isaqueprofeta/zabbix-pipe2bash/main/zbx60_rh8_pgtdb_nginx.sh | bash -s Z4bb1xD4t4b4s3
```

- Ubuntu 22.04:

```sh
curl -sSL https://raw.githubusercontent.com/isaqueprofeta/zabbix-pipe2bash/main/zbx60_jammy_pgtdb_nginx.sh | bash -s M1nh4S3NH4D0BancoD3D4d05
```
