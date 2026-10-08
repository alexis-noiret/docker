# Bonus - Bonus : l'équivalent de XAMPP

> **Consigne** : Avec un fichier Dockerfile et un fichier yml : un serveur nginx (ou apache) avec PHP, un serveur MariaDB/MySQL avec phpMyAdmin, un serveur FTP, et un volume pour stocker l'ensemble des données communes aux différents serveurs. Tester le système.

```dockerfile
FROM php:8.3-apache
RUN docker-php-ext-install mysqli
```

```php
<?php
mysqli_report(MYSQLI_REPORT_OFF);
$c = @new mysqli('db', 'app', 'app123', 'appdb');
echo "<h1>Alexis Noiret - stack LAMP Docker</h1>";
echo $c->connect_errno
    ? "<p>MariaDB : ERREUR " . $c->connect_error . "</p>"
    : "<p>MariaDB : connexion OK (version " . $c->server_info . ")</p>";
echo "<p>PHP " . phpversion() . "</p>";
```

```yaml
services:
  web:
    build: .
    container_name: bonus-web
    ports:
      - "80:80"
    volumes:
      - web-data:/var/www/html
    depends_on:
      - db

  db:
    image: mariadb:lts
    container_name: bonus-db
    environment:
      MARIADB_ROOT_PASSWORD: root123
      MARIADB_DATABASE: appdb
      MARIADB_USER: app
      MARIADB_PASSWORD: app123
    volumes:
      - db-data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin:latest
    container_name: bonus-phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
    depends_on:
      - db

  ftp:
    image: delfer/alpine-ftp-server
    container_name: bonus-ftp
    ports:
      - "21:21"
      - "21000-21010:21000-21010"
    environment:
      USERS: "alexis|ftp123|/var/www/html"
      ADDRESS: 192.168.109.135
      MIN_PORT: 21000
      MAX_PORT: 21010
    volumes:
      - web-data:/var/www/html

volumes:
  web-data:
  db-data:
```

| Service | Rôle |
|---|---|
| `web` | Apache + PHP 8.3 (image construite avec l'extension `mysqli`), port 80 |
| `db` | MariaDB, base `appdb`, données dans le volume `db-data` |
| `phpmyadmin` | Administration de la base, port 8080 |
| `ftp` | Dépôt de fichiers dans le dossier web, port 21 |
| Volume `web-data` | Partagé par `web` et `ftp` : un fichier déposé en FTP est servi par Apache |

```bash
# la stack du job 7 occupe déjà les ports 80 et 21 : elle est arrêtée avant
docker compose up -d --build
docker compose ps
docker exec bonus-ftp chown -R alexis /var/www/html
curl -T index.php ftp://alexis:ftp123@localhost/      # dépôt de la page par FTP
```

![Construction de l'image `bonus-web` et téléchargement de `mariadb` et `phpmyadmin`](../docs/images/bonus-compose-up-debut.png)

*Construction de l'image `bonus-web` et téléchargement de `mariadb` et `phpmyadmin`*

![Réseau, volumes et 4 conteneurs créés](../docs/images/bonus-compose-up-fin.png)

*Réseau, volumes et 4 conteneurs créés*

![`docker compose ps` : les 4 services en cours d'exécution](../docs/images/bonus-compose-ps.png)

*`docker compose ps` : les 4 services en cours d'exécution*

## Tests

![`http://192.168.109.135` : PHP 8.3.35 et connexion à MariaDB réussie](../docs/images/bonus-page-php.png)

*`http://192.168.109.135` : PHP 8.3.35 et connexion à MariaDB réussie*

![`http://192.168.109.135:8080` : phpMyAdmin connecté au serveur `db`, base `appdb` visible](../docs/images/bonus-phpmyadmin.png)

*`http://192.168.109.135:8080` : phpMyAdmin connecté au serveur `db`, base `appdb` visible*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| « MariaDB : ERREUR » juste après le démarrage | MariaDB met quelques secondes à s'initialiser au premier lancement | Attendre 10 secondes et recharger la page |

## À retenir

- Les services se joignent par leur nom (`db`) sur le réseau créé par compose : aucune adresse IP à connaître.
- Les données de la base sont dans un volume nommé : elles survivent à `docker compose down` (mais pas à `down -v`).

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./bonus-lamp/bonus.sh` (nettoyage : `./bonus-lamp/bonus.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
