# Job 07 - nginx + FTP avec un volume commun (docker compose)

> **Consigne** : À l'aide d'un fichier yml et de docker compose, faire deux conteneurs liés, nginx et FTP, avec un volume commun pour le dossier web. Créer un index.html avec son nom/prénom sur son PC, installer FileZilla, se connecter en FTP au conteneur, envoyer le fichier et regarder le résultat.

```yaml
services:
  nginx:
    image: nginx:latest
    container_name: web-nginx
    ports:
      - "80:80"
    volumes:
      - web-data:/usr/share/nginx/html
    depends_on:
      - ftp

  ftp:
    image: delfer/alpine-ftp-server
    container_name: web-ftp
    ports:
      - "21:21"
      - "21000-21010:21000-21010"
    environment:
      USERS: "alexis|ftp123|/usr/share/nginx/html"
      ADDRESS: 192.168.109.135      # IP de la VM, annoncée en mode passif
      MIN_PORT: 21000
      MAX_PORT: 21010
    volumes:
      - web-data:/usr/share/nginx/html

volumes:
  web-data:
```

Le volume `web-data` est monté dans les deux conteneurs : ce qui est déposé par FTP dans `/usr/share/nginx/html` est immédiatement servi par nginx. La plage de ports 21000-21010 est celle du **mode passif** FTP.

```bash
docker compose up -d
docker compose ps
docker exec web-ftp chown -R alexis /usr/share/nginx/html   # l'utilisateur FTP doit pouvoir écrire
```

Sur le PC : `index.html` contenant mon nom, envoyé avec **FileZilla** (hôte `192.168.109.135`, utilisateur `alexis`, port 21).

```html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Job 7</title></head>
<body><h1>Alexis Noiret</h1></body>
</html>
```

![FileZilla : `index.html` envoyé dans `/usr/share/nginx/html` ; à gauche la page servie par nginx](../docs/images/job07-filezilla-navigateur.png)

*FileZilla : `index.html` envoyé dans `/usr/share/nginx/html` ; à gauche la page servie par nginx*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Envoi FTP refusé (permission) | Le volume appartient à root, l'utilisateur FTP `alexis` ne peut pas y écrire | `docker exec web-ftp chown -R alexis /usr/share/nginx/html` |
| FileZilla se connecte mais n'affiche pas les fichiers | Mode passif : les ports et l'adresse annoncée doivent correspondre à la VM | Publier `21000-21010` et renseigner `ADDRESS` avec l'IP de la VM |

## À retenir

- Les services d'un fichier compose se joignent par leur nom grâce au réseau créé par compose.
- FTP transmet les mots de passe en clair : SFTP ou FTPS en production.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job07/job07.sh` (nettoyage : `./job07/job07.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
