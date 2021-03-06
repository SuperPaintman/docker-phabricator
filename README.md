# Docker Phabricator

[![Image Layers][imagelayers-image]][imagelayers-url]

[Docker][docker-url] image for [Phabricator][phabricator-url]


## Usage with docker-compose

**docker-compose.yml**

```yaml
version: "2"
services:
  # Phabricator
  phabricator:
    image: superpaintman/phabricator

    container_name: phabricator

    restart: always

    ports:
      - "222:22"
      # - "9000:9000"
    volumes:
      - /apps/phabricator/phabricator:/var/www/phabricator
      - /apps/phabricator/files:/var/www/files
      - /var/repo:/var/repo

    networks:
      - phabricator_network

    environment:
      PHABRICATOR_BASEURI: https://example.com/
      PHABRICATOR_STORAGE_LOCAL_DISK_PATH: /var/www/files
      PHABRICATOR_REPO_LOCAL_DISK_PATH: /var/repo

      PHABRICATOR_DB_HOST: mariadb
      PHABRICATOR_DB_PORT: 3306
      PHABRICATOR_DB_USER: root # Phabricator required root permissions
      PHABRICATOR_DB_PASS: toor

  # MariaDB
  phabricator-mariadb:
    image: mariadb
    
    container_name: phabricator-mariadb

    restart: always

    ports:
      - "3306:3306"
    volumes:
      - /etc/mysql/conf.d:/etc/mysql/conf.d:ro
      - /var/lib/mysql/phabricator:/var/lib/mysql
    volumes_from:
      - phabricator

    networks:
      phabricator_network:
        aliases:
          - mariadb

    environment:
      MYSQL_ROOT_PASSWORD: toor

  # Nginx
  nginx:
    image: nginx:1.9.14

    container_name: nginx

    restart: always

    volumes:
      - /etc/nginx:/etc/nginx

    ports:
      - "80:80"
      - "443:443"

    links:
      - phabricator:phabricator

networks:
  phabricator_network:
    driver: bridge
```


**example.com** - Nginx config

```nginx
###
# example.com
###
upstream example_com {
    server phabricator:9000;
}

server {
    listen       443 ssl http2;
    server_name  example.com;

    # Logs
    access_log   /var/log/nginx/example.com.log;
    error_log    /var/log/nginx/example.com.log;

    # SSL
    include      /etc/nginx/snippets/ssl.conf;
    include      /etc/nginx/snippets/ssl_example.com.conf;

    # GZIP
    include      /etc/nginx/snippets/gzip.conf;

    # Proxy
    location / {
        index index.php;
        rewrite ^/(.*)$ /index.php?__path__=/$1 last;
    }

    location /index.php {
        include fastcgi_params;

        root              /var/www/phabricator/webroot;

        fastcgi_index     index.php;
        fastcgi_param     SCRIPT_FILENAME $document_root/$fastcgi_script_name;

        fastcgi_pass      example_com;
    }
}

server {
    listen          80;
    server_name     example.com;
    rewrite         ^ https://$server_name$request_uri? permanent;
}
```

--------------------------------------------------------------------------------

## Configuring
### Volumes
|Volume                  |Required|Comment|
|------------------------|--------|-------|
|**/var/www/libphutil**  |`No`    |       |
|**/var/www/arcanist**   |`No`    |       |
|**/var/www/phabricator**|`Yes`   |       |
|**/var/www/files**      |`Yes`   |       |
|**/var/repo**           |`Yes`   |       |

### Environment variables
|Env                                    |Config key                   |Comment|Default           |
|---------------------------------------|-----------------------------|-------|------------------|
|**PHABRICATOR_BASEURI**                |phabricator.base-uri         |       |*null*            |
|**PHABRICATOR_STORAGE_LOCAL_DISK_PATH**|storage.local-disk.path      |       |*"/var/www/files"*|
|**PHABRICATOR_REPO_LOCAL_DISK_PATH**   |repository.default-local-path|       |*"/var/repo"*     |
|**PHABRICATOR_DB_HOST**                |mysql.host                   |       |*"localhost"*     |
|**PHABRICATOR_DB_PORT**                |mysql.port                   |       |*"3306"*          |
|**PHABRICATOR_DB_USER**                |mysql.user                   |       |*"root"*          |
|**PHABRICATOR_DB_PASS**                |mysql.pass                   |       |*""*              |

[docker-url]: //www.docker.com/
[phabricator-url]: //phabricator.org/
[imagelayers-image]: //badge.imagelayers.io/superpaintman/phabricator:latest.svg
[imagelayers-url]: //imagelayers.io/?images=superpaintman%2Fphabricator:latest