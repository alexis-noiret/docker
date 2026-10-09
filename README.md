# 🐳 Docker - Conteneurisation

> Découverte de Docker : images, conteneurs, Dockerfile, volumes, docker compose, registry local, Portainer.

Projet réalisé dans le cadre du **Bachelor IT Cybersécurité** - La Plateforme, par **Alexis Noiret**.

Le sujet comporte 11 jobs et un bonus (« Pour aller plus loin »). Tout a été réalisé **à la main** sur une VM Debian ; ce dépôt contient la documentation de chaque job (commandes, fichiers, captures, problèmes rencontrés), ainsi que des scripts de démonstration facultatifs.

---

## Environnement

| Élément | Valeur |
|---|---|
| Hyperviseur | VMware Workstation |
| VM | Debian 13 (trixie), mode console, 8 Go de disque, 1 Go de RAM, 1 vCPU |
| Docker | Docker Engine 29.8.2, Compose v5.6.0 (dépôt officiel) |
| Portainer | CE 2.45.2 LTS |
| PC | EndeavourOS (terminal Konsole, FileZilla, Chrome) |
| Réseau | VM en DHCP (192.168.109.135), accès SSH depuis le PC |

Les mots de passe du dépôt (`root123`, `ftp123`, `app123`...) sont ceux d'un laboratoire jetable, demandés par l'énoncé. Ils ne doivent jamais servir en production.

## Sommaire

- [Job 01 - Installer Docker (CLI seulement)](job01/README.md)
- [Job 02 - Tester l'installation : hello-world](job02/README.md)
- [Job 03 - Dockerfile : recréer hello-world depuis une image Debian](job03/README.md)
- [Job 04 - Dockerfile : une image SSH](job04/README.md)
- [Job 05 - Alias Docker dans ~/.bashrc](job05/README.md)
- [Job 06 - Volumes entre deux conteneurs](job06/README.md)
- [Job 07 - nginx + FTP avec un volume commun (docker compose)](job07/README.md)
- [Job 08 - Dockerfile : nginx sans image nginx](job08/README.md)
- [Job 09 - Registry local et interface web](job09/README.md)
- [Job 10 - Scripts d'installation et de désinstallation de Docker](job10/README.md)
- [Job 11 - Portainer](job11/README.md)
- [Bonus - Bonus : l'équivalent de XAMPP](bonus-lamp/README.md)

---

## Job 01 - Installer Docker (CLI seulement)

> **Consigne** : Créer une VM Debian en mode console (8 Go de disque, 1 Go de RAM, 1 vCPU) et installer Docker, en ligne de commande seulement.

La VM tourne sous VMware Workstation : Debian 13 (trixie) en mode console, sans environnement de bureau, avec le serveur SSH pour s'y connecter depuis mon PC. Docker est installé depuis le **dépôt officiel** (et non le paquet `docker.io` de Debian) pour avoir une version à jour, avec les plugins `compose` et `buildx`.

```bash
# la source « cdrom » faisait réclamer le DVD d'installation à apt : on la désactive
sudo sed -i 's/^deb cdrom/# deb cdrom/' /etc/apt/sources.list

sudo apt update
sudo apt install -y ca-certificates curl

# clé GPG et dépôt officiel de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# utiliser docker sans sudo (se reconnecter ensuite)
sudo usermod -aG docker $USER
```

Vérification : le service est actif et activé au démarrage.

```bash
docker --version
docker compose version
systemctl status docker
```

![`systemctl status docker` : service actif (running) et enabled](docs/images/job01-systemctl-status-docker.png)

*`systemctl status docker` : service actif (running) et enabled*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| apt demande le DVD d'installation | La ligne `deb cdrom` reste dans `/etc/apt/sources.list` après l'installation | La commenter avec `sed` |
| `permission denied` sur `/var/run/docker.sock` | L'utilisateur n'est pas dans le groupe `docker` | `usermod -aG docker $USER`, puis se déconnecter et se reconnecter |

### À retenir

- Docker = un démon (`dockerd`) + un client (`docker`) qui lui parle via un socket Unix.
- Appartenir au groupe `docker` équivaut à être root sur la machine.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job01/job01.sh` (nettoyage : `./job01/job01.sh clean`). Le script ne fait que ce job.


---

## Job 02 - Tester l'installation : hello-world

> **Consigne** : Tester l'installation de Docker avec le conteneur « hello-world » et se familiariser avec les commandes.

```bash
docker run hello-world      # télécharge l'image, crée et lance le conteneur
docker ps                   # conteneurs en cours d'exécution
docker ps -a                # tous les conteneurs, y compris arrêtés
docker images               # images présentes en local
docker logs <conteneur>     # sortie d'un conteneur
docker rm <conteneur>       # supprimer un conteneur
docker rmi hello-world      # supprimer l'image (après le conteneur)
```

![`docker run hello-world` : l'image est téléchargée puis le message s'affiche](docs/images/job02-hello-world.png)

*`docker run hello-world` : l'image est téléchargée puis le message s'affiche*

Le message décrit lui-même le fonctionnement : le client contacte le démon, le démon télécharge l'image depuis Docker Hub, crée un conteneur qui exécute le programme, puis renvoie la sortie au client. Le conteneur se termine aussitôt (`Exited (0)`).

### À retenir

- Image = modèle en lecture seule ; conteneur = instance de cette image.
- Un conteneur arrêté existe toujours (`docker ps -a`) tant qu'il n'est pas supprimé, et empêche de supprimer son image.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job02/job02.sh` (nettoyage : `./job02/job02.sh clean`). Le script ne fait que ce job.


---

## Job 03 - Dockerfile : recréer hello-world depuis une image Debian

> **Consigne** : Utiliser un Dockerfile pour recréer le conteneur « hello-world » depuis une image Debian minimale.

L'objectif est que mon image Debian affiche **exactement le même message** que `hello-world`. Je récupère donc la vraie sortie de `hello-world` dans un fichier, que je copie dans l'image.

```bash
mkdir -p ~/docker/job03 && cd ~/docker/job03
docker run --rm hello-world > message.txt

cat > Dockerfile <<'EOF'
FROM debian:stable-slim
COPY message.txt /message.txt
CMD ["cat", "/message.txt"]
EOF

docker build -t hello-debian .
docker run --rm hello-debian
```

![Le Dockerfile](docs/images/job03-dockerfile.png)

*Le Dockerfile*

![Construction de l'image `hello-debian`](docs/images/job03-build.png)

*Construction de l'image `hello-debian`*

Comparaison des deux sorties avec `diff` : elles sont identiques.

```bash
diff <(docker run --rm hello-debian) <(docker run --rm hello-world) && echo "Identique"
```

![Les deux sorties sont identiques](docs/images/job03-diff-identique.png)

*Les deux sorties sont identiques*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Première version : message personnalisé au lieu du vrai message | Le sujet demande de recréer `hello-world`, pas d'afficher un texte libre | Reprendre la sortie réelle de `hello-world` et vérifier avec `diff` |

### À retenir

- `FROM` choisit l'image de base, `COPY` ajoute un fichier (nouvelle couche), `CMD` est la commande lancée au démarrage.
- `docker history hello-debian` montre les couches de l'image.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job03/job03.sh` (nettoyage : `./job03/job03.sh clean`). Le script ne fait que ce job.


---

## Job 04 - Dockerfile : une image SSH

> **Consigne** : Créer une image SSH (compte root, mot de passe root123) sans utiliser d'image SSH existante, avec une redirection de port autre que 22, puis lancer le conteneur et s'y connecter.

```dockerfile
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server && \
    mkdir -p /run/sshd && \
    echo "root:root123" | chpasswd && \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

![Le Dockerfile](docs/images/job04-dockerfile.png)

*Le Dockerfile*

- `mkdir -p /run/sshd` : répertoire exigé par sshd, absent de l'image.
- `PermitRootLogin yes` : Debian refuse la connexion root par mot de passe par défaut.
- `sshd -D` : sshd reste au premier plan, sinon le conteneur s'arrête immédiatement.
- `-p 2222:22` : le port 2222 de la VM est redirigé vers le port 22 du conteneur.

```bash
docker build -t ssh-debian .
docker run -d --name ssh-test -p 2222:22 ssh-debian
docker ps
ssh root@192.168.109.135 -p 2222       # mot de passe : root123
```

![Build, lancement avec `2222->22`, puis connexion SSH au conteneur](docs/images/job04-build-run-ssh.png)

*Build, lancement avec `2222->22`, puis connexion SSH au conteneur*

Test depuis la VM elle-même (le prompt `root@a372aaa732f9` est celui du conteneur) :

![`ssh root@localhost -p 2222` depuis la VM : on est dans le conteneur Debian](docs/images/job04-ssh-localhost.png)

*`ssh root@localhost -p 2222` depuis la VM : on est dans le conteneur Debian*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| `ssh: Could not resolve hostname ip_vm` | J'avais recopié le texte `IP_VM` de l'exemple au lieu de l'adresse réelle | Utiliser l'IP de la VM : `192.168.109.135` |

### À retenir

- `EXPOSE` documente seulement ; c'est `-p` qui publie le port.
- Un conteneur n'a pas de systemd : un seul processus au premier plan.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job04/job04.sh` (nettoyage : `./job04/job04.sh clean`). Le script ne fait que ce job.


---

## Job 05 - Alias Docker dans ~/.bashrc

> **Consigne** : Tout informaticien étant « flemmard », faire des alias pour les commandes Docker en CLI, à mettre dans ~/.bashrc, pour manipuler les images et les conteneurs.

Les alias sont ajoutés à la fin de `~/.bashrc`, puis chargés avec `source ~/.bashrc`.

![Le bloc d'alias dans `~/.bashrc`](docs/images/job05-alias-bashrc.png)

*Le bloc d'alias dans `~/.bashrc`*

```bash
source ~/.bashrc
alias | grep docker
dps          # docker ps
dpsa         # docker ps -a
di           # docker images
dex ssh-test bash   # docker exec -it ssh-test bash
```

![Liste des alias, puis utilisation de `dpsa`, `di` et `dex`](docs/images/job05-alias-usage.png)

*Liste des alias, puis utilisation de `dpsa`, `di` et `dex`*

### À retenir

- Un alias n'existe que dans les shells interactifs qui lisent `~/.bashrc` : il ne fonctionne pas dans un script.
- `dstopall` et `drmall` utilisent `$(docker ps -q)` : pratiques mais destructeurs.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job05/job05.sh` (nettoyage : `./job05/job05.sh clean`). Le script ne fait que ce job.


---

## Job 06 - Volumes entre deux conteneurs

> **Consigne** : Se renseigner sur l'utilisation de volumes entre deux conteneurs et sur la gestion des volumes.

| Type | Syntaxe | Où sont les données | Usage |
|---|---|---|---|
| Volume nommé | `-v mon-volume:/data` | Géré par Docker (`/var/lib/docker/volumes`) | Données à conserver, partage entre conteneurs |
| Bind mount | `-v /chemin/hote:/data` | Un dossier de la machine hôte | Développement, configuration |
| tmpfs | `--tmpfs /data` | En mémoire, perdu à l'arrêt | Données temporaires ou sensibles |

Démonstration : deux conteneurs `c1` et `c2` montent le **même volume**. Ce que `c1` écrit, `c2` le lit.

```bash
docker volume create mon-volume
docker volume ls
docker volume inspect mon-volume

docker run --rm -v mon-volume:/data debian bash -c "echo 'bonjour' > /data/test.txt"
docker run --rm -v mon-volume:/data debian cat /data/test.txt     # le fichier a survécu au conteneur

docker run -d --name c1 -v mon-volume:/data debian sleep 3600
docker run -d --name c2 -v mon-volume:/data debian sleep 3600
docker exec c1 bash -c "echo 'depuis c1' >> /data/test.txt"
docker exec c2 cat /data/test.txt                                  # c2 voit « bonjour » et « depuis c1 »

docker rm -f c1 c2
docker volume rm mon-volume
docker volume prune
```

![Création, inspection, partage entre `c1` et `c2`, puis suppression](docs/images/job06-volumes-cli.png)

*Création, inspection, partage entre `c1` et `c2`, puis suppression*

### À retenir

- Le volume survit à la suppression des conteneurs : c'est ce qui conserve une base de données.
- `docker volume inspect` donne le `Mountpoint` réel sur la VM (`/var/lib/docker/volumes/mon-volume/_data`).
- Deux conteneurs qui écrivent en même temps dans le même fichier peuvent se gêner : Docker ne pose pas de verrou.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job06/job06.sh` (nettoyage : `./job06/job06.sh clean`). Le script ne fait que ce job.


---

## Job 07 - nginx + FTP avec un volume commun (docker compose)

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

![FileZilla : `index.html` envoyé dans `/usr/share/nginx/html` ; à gauche la page servie par nginx](docs/images/job07-filezilla-navigateur.png)

*FileZilla : `index.html` envoyé dans `/usr/share/nginx/html` ; à gauche la page servie par nginx*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Envoi FTP refusé (permission) | Le volume appartient à root, l'utilisateur FTP `alexis` ne peut pas y écrire | `docker exec web-ftp chown -R alexis /usr/share/nginx/html` |
| FileZilla se connecte mais n'affiche pas les fichiers | Mode passif : les ports et l'adresse annoncée doivent correspondre à la VM | Publier `21000-21010` et renseigner `ADDRESS` avec l'IP de la VM |

### À retenir

- Les services d'un fichier compose se joignent par leur nom grâce au réseau créé par compose.
- FTP transmet les mots de passe en clair : SFTP ou FTPS en production.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job07/job07.sh` (nettoyage : `./job07/job07.sh clean`). Le script ne fait que ce job.


---

## Job 08 - Dockerfile : nginx sans image nginx

> **Consigne** : Sans utiliser d'image nginx existante, utiliser un Dockerfile pour créer un conteneur nginx, gérer la redirection de port et s'y connecter.

```dockerfile
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

COPY index.html /var/www/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

![`index.html` et Dockerfile](docs/images/job08-index-dockerfile.png)

*`index.html` et Dockerfile*

```bash
docker build -t nginx-debian .
docker run -d --name nginx-test -p 8081:80 nginx-debian
docker ps
curl http://localhost:8081
```

![Build, lancement sur le port 8081 et `curl`](docs/images/job08-build-run-curl.png)

*Build, lancement sur le port 8081 et `curl`*

![La page dans le navigateur : `http://192.168.109.135:8081`](docs/images/job08-navigateur.png)

*La page dans le navigateur : `http://192.168.109.135:8081`*

Comparaison de taille avec l'image officielle (déjà utilisée au job 7) :

![`nginx-debian` : 132 Mo sur disque, contre 243 Mo pour `nginx:latest`](docs/images/job08-images-ps.png)

*`nginx-debian` : 132 Mo sur disque, contre 243 Mo pour `nginx:latest`*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Le conteneur s'arrêterait immédiatement | nginx se lance en démon (arrière-plan) par défaut, et Docker arrête le conteneur quand le processus principal se termine | `CMD ["nginx", "-g", "daemon off;"]` pour rester au premier plan |

### À retenir

- Port 8081 = côté VM ; port 80 = côté conteneur. Le port 80 de la VM est déjà pris par le job 7.
- `--no-install-recommends` et la suppression du cache apt dans le même `RUN` allègent l'image.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job08/job08.sh` (nettoyage : `./job08/job08.sh clean`). Le script ne fait que ce job.


---

## Job 09 - Registry local et interface web

> **Consigne** : Créer et utiliser un « registry » local, et ajouter une « UI » pour le gérer depuis une interface web.

```yaml
services:
  registry:
    image: registry:2
    container_name: registry
    ports:
      - "5000:5000"
    environment:
      REGISTRY_STORAGE_DELETE_ENABLED: "true"
    volumes:
      - registry-data:/var/lib/registry

  registry-ui:
    image: joxit/docker-registry-ui:latest
    container_name: registry-ui
    ports:
      - "8082:80"
    environment:
      SINGLE_REGISTRY: "true"
      REGISTRY_TITLE: "Registry local"
      DELETE_IMAGES: "true"
      NGINX_PROXY_PASS_URL: "http://registry:5000"
    depends_on:
      - registry

volumes:
  registry-data:
```

![Le fichier `docker-compose.yml`](docs/images/job09-compose.png)

*Le fichier `docker-compose.yml`*

`registry:2` est le registry officiel ; `joxit/docker-registry-ui` fournit l'interface et passe par un proxy interne (`NGINX_PROXY_PASS_URL`). Le nom d'une image contient l'adresse du registry : `localhost:5000/nginx-debian:v1`.

```bash
docker compose up -d
docker compose ps

docker tag nginx-debian localhost:5000/nginx-debian:v1
docker push localhost:5000/nginx-debian:v1
curl http://localhost:5000/v2/_catalog          # {"repositories":["nginx-debian"]}

docker rmi localhost:5000/nginx-debian:v1 nginx-debian    # on supprime la copie locale...
docker pull localhost:5000/nginx-debian:v1                # ...et on la récupère depuis le registry
```

![Démarrage des deux conteneurs, `tag`, `push`, `_catalog`, puis `rmi` et `pull`](docs/images/job09-compose-up-push.png)

*Démarrage des deux conteneurs, `tag`, `push`, `_catalog`, puis `rmi` et `pull`*

![Interface web (`:8082`) : le dépôt `nginx-debian`](docs/images/job09-registry-ui.png)

*Interface web (`:8082`) : le dépôt `nginx-debian`*

![Le tag `v1` (amd64, 33 Mo)](docs/images/job09-registry-ui-tags.png)

*Le tag `v1` (amd64, 33 Mo)*

### À retenir

- Docker accepte `localhost:5000` en HTTP. Depuis une autre machine il faut TLS ou déclarer le registry dans `insecure-registries` (`/etc/docker/daemon.json`).
- Ce registry n'a pas d'authentification : à protéger hors laboratoire.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job09/job09.sh` (nettoyage : `./job09/job09.sh clean`). Le script ne fait que ce job.


---

## Job 10 - Scripts d'installation et de désinstallation de Docker

> **Consigne** : Faire un script bash pour effacer totalement Docker (images, volumes, conteneurs et paquets correspondants) et rendre le système propre, et aussi un script pour automatiser l'installation de Docker sur une machine Debian.

Deux scripts : [`uninstall-docker.sh`](job10/uninstall-docker.sh) et [`install-docker.sh`](job10/install-docker.sh).

### uninstall-docker.sh

![Le script de désinstallation](docs/images/job10-cat-uninstall.png)

*Le script de désinstallation*

1. Vérifie qu'il est lancé en root et demande confirmation (`oui`).
2. Supprime conteneurs, volumes, réseaux et images (`xargs -r` évite d'appeler la commande sans argument).
3. Arrête `docker`, `docker.socket` et `containerd`.
4. Purge chaque paquet Docker installé (`dpkg -l`), puis `autoremove --purge`.
5. Supprime `/var/lib/docker`, `/var/lib/containerd`, `/etc/docker`, le dépôt et la clé GPG, et le groupe `docker`.

![Exécution : confirmation, arrêt des services, purge des paquets](docs/images/job10-uninstall-1.png)

*Exécution : confirmation, arrêt des services, purge des paquets*

![Fin de l'exécution : « Docker est complètement supprimé. »](docs/images/job10-uninstall-2.png)

*Fin de l'exécution : « Docker est complètement supprimé. »*

### install-docker.sh

![Le script d'installation](docs/images/job10-cat-install.png)

*Le script d'installation*

Il reprend la procédure du job 1 en 5 étapes numérotées, avec `set -e` pour s'arrêter à la première erreur, et se termine par un test `hello-world`.

![Exécution : prérequis, clé GPG, dépôt, installation](docs/images/job10-install-debut.png)

*Exécution : prérequis, clé GPG, dépôt, installation*

![Fin : `hello-world`, « Docker est installé. », puis `docker --version` et `docker compose version`](docs/images/job10-install-fin.png)

*Fin : `hello-world`, « Docker est installé. », puis `docker --version` et `docker compose version`*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| `apt` échoue : verrou `dpkg` déjà pris | Un autre processus apt (mise à jour automatique) tenait le verrou pendant la désinstallation | `apt-get -o DPkg::Lock::Timeout=120` : apt attend jusqu'à 2 minutes au lieu d'échouer |

### À retenir

- `purge` supprime aussi les fichiers de configuration, contrairement à `remove`.
- Limite connue : `uninstall-docker.sh` n'a pas de `set -e` et affiche « complètement supprimé » sans contrôler le résultat d'apt. Amélioration possible : `set -e` et une vérification finale (`command -v docker`, `dpkg -l`).


---

## Job 11 - Portainer

> **Consigne** : Découvrir Portainer. Refaire les jobs 2 à 9 en utilisant l'interface graphique de Portainer. Se renseigner sur les alternatives à Portainer.

### Installation de Portainer CE

```bash
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```

![Installation de Portainer CE (2.45.2 LTS)](docs/images/job11-portainer-install.png)

*Installation de Portainer CE (2.45.2 LTS)*

Interface : `https://192.168.109.135:9443` (certificat auto-signé). Le compte administrateur doit être créé dans les **5 minutes** qui suivent le démarrage ; au-delà, Portainer se verrouille : `docker restart portainer`. Il faut ensuite cliquer sur l'environnement **local** pour voir les menus Containers, Images et Volumes.

`/var/run/docker.sock` est monté dans le conteneur : Portainer contrôle ainsi le démon Docker de l'hôte, ce qui équivaut à un accès root. Le compte administrateur doit donc être protégé.

### Job 2 - hello-world
`Containers > Add container`, image `hello-world`, `Deploy the container`, puis l'icône **Logs**.

![Logs des conteneurs `hello-world` (à gauche) et `hello-debian-test` (à droite)](docs/images/job11-job02-logs.png)

*Logs des conteneurs `hello-world` (à gauche) et `hello-debian-test` (à droite)*

### Job 3 - image depuis un Dockerfile
Portainer construit une image depuis une archive : `Images > Build a new image > Upload`. Le Dockerfile doit être à la racine de l'archive.

```bash
cd ~/docker/job03
tar -cf job03.tar Dockerfile message.txt
tar -tf job03.tar
# récupération sur le PC : scp alexis@192.168.109.135:~/docker/job03/job03.tar ~/
```

![Sortie du build : `Successfully tagged hello-debian:latest`](docs/images/job11-job03-build-sortie.png)

*Sortie du build : `Successfully tagged hello-debian:latest`*

### Job 4 - image SSH
Build avec le **Web editor** (le Dockerfile est collé dans l'interface), puis conteneur `ssh-test` avec le port `2222` vers `22`.

![Build de `ssh-debian` avec le Web editor](docs/images/job11-job04-build-web-editor.png)

*Build de `ssh-debian` avec le Web editor*

![Détail du conteneur `ssh-test`](docs/images/job11-job04-ssh-test-details.png)

*Détail du conteneur `ssh-test`*

![Liste des conteneurs : `ssh-test` publie `2222:22`](docs/images/job11-job04-conteneurs.png)

*Liste des conteneurs : `ssh-test` publie `2222:22`*

### Job 5 - alias
Pas d'équivalent dans Portainer : un alias est un raccourci du shell.

### Job 6 - volumes
`Volumes > Add volume`, puis deux conteneurs `c1` et `c2` qui montent le même volume (`Advanced container settings > Volumes`). La console (icône `>_`) permet de vérifier : `c2` lit le fichier écrit par `c1`.

![Conteneurs `c1` et `c2`](docs/images/job11-job06-conteneurs.png)

*Conteneurs `c1` et `c2`*

![Console de `c2` : `cat /data/test.txt` affiche « depuis c1 »](docs/images/job11-job06-console-c2.png)

*Console de `c2` : `cat /data/test.txt` affiche « depuis c1 »*

### Job 7 - nginx + FTP
`Stacks > Add stack`, nom `job07`, le YAML du job 7 collé dans le Web editor, `Deploy the stack`. Le `chown` se fait dans la console du conteneur `web-ftp`.

![Stack `job07` : `web-ftp` et `web-nginx` en cours d'exécution](docs/images/job11-job07-stack.png)

*Stack `job07` : `web-ftp` et `web-nginx` en cours d'exécution*

![Console de `web-ftp` : `chown -R alexis /usr/share/nginx/html`](docs/images/job11-job07-chown-console.png)

*Console de `web-ftp` : `chown -R alexis /usr/share/nginx/html`*

### Job 8 - nginx depuis un Dockerfile
Build de l'archive `job08.tar` (`Dockerfile` + `index.html`), puis conteneur `nginx-job08` avec le port `8081` vers `80`. L'option **« Always pull the image »** doit être **désactivée** : l'image `nginx-debian:job08` n'existe qu'en local.

![Sortie du build : `Successfully tagged nginx-debian:job08`](docs/images/job11-job08-build-sortie.png)

*Sortie du build : `Successfully tagged nginx-debian:job08`*

![`nginx-job08` publie `8081:80` ; la stack `job07` tourne toujours](docs/images/job11-job08-conteneurs.png)

*`nginx-job08` publie `8081:80` ; la stack `job07` tourne toujours*

### Job 9 - registry
Stack `job09` avec le YAML du job 9, puis `Registries > Add registry > Custom registry` pour déclarer `192.168.109.135:5000`.

![Création de la stack `job09`](docs/images/job11-job09-stack.png)

*Création de la stack `job09`*

![`tag` et `push` dans le terminal ; `registry` et `registry-ui` apparaissent dans Portainer](docs/images/job11-job09-tag-push.png)

*`tag` et `push` dans le terminal ; `registry` et `registry-ui` apparaissent dans Portainer*

![Interface du registry (tag `job08`) et registry `registry-local` ajouté dans Portainer](docs/images/job11-job09-registry-local.png)

*Interface du registry (tag `job08`) et registry `registry-local` ajouté dans Portainer*

### Alternatives à Portainer
| Outil | Type | Points clés | Limites |
|---|---|---|---|
| **Dockge** | Interface web | Centré sur les stacks Compose, éditeur YAML, terminal web, multi-hôte par agents. Les `compose.yaml` restent sur le disque. Licence MIT, environ 50 Mo de RAM contre environ 200 Mo pour Portainer | Pas de Kubernetes ni de Swarm ; gestion limitée des conteneurs hors Compose |
| **Yacht** | Interface web | Modèles d'applications, gestion basique des conteneurs | Abandonné : aucune mise à jour depuis janvier 2023, versions alpha uniquement |
| **Lazydocker** | Terminal (TUI) | Un seul binaire, conteneurs, logs et stats dans le terminal | Pas d'interface graphique ni multi-utilisateur |
| **Cockpit** | Administration système | Gère tout le serveur, avec un module conteneurs | Module conteneurs surtout orienté Podman |
| **Rancher** | Plateforme | Gestion de clusters Kubernetes | Surdimensionné pour un seul hôte Docker |

Dockge convient pour un hôte unique centré sur Docker Compose. Portainer reste plus complet (images, volumes, réseaux, registries, multi-hôte, Kubernetes), mais RBAC, SSO et audit sont réservés à l'édition Business payante. Dockge, Yacht et Portainer montent tous le socket Docker et partagent donc le même risque.

Sources : [ossalt.com](https://ossalt.com/guides/portainer-vs-yacht-vs-dockge-2026), [selfhosting.sh (Yacht)](https://selfhosting.sh/apps/yacht/), [README de Dockge](https://raw.githubusercontent.com/louislam/dockge/master/README.md).

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Page de setup « expirée » ou menus absents | Portainer se verrouille 5 minutes après son démarrage ; les menus n'apparaissent qu'une fois l'environnement `local` sélectionné | `docker restart portainer`, créer le compte, puis cliquer sur `local` |
| Le conteneur du job 8 ne démarre pas | « Always pull the image » cherchait `nginx-debian` sur Docker Hub | Désactiver l'option (image locale) |
| Bouton `Deploy` grisé | Une ligne de port vide dans le formulaire | Supprimer la ligne vide |

### À retenir

- Docker Hub limite les téléchargements anonymes (100 pulls / 6 h) : visible dans Portainer, section Registries.
- Portainer facilite la visibilité (logs, inspect, console), mais une stack ou un script restent plus reproductibles.

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job11/job11.sh` (nettoyage : `./job11/job11.sh clean`). Le script ne fait que ce job.


---

## Bonus - Bonus : l'équivalent de XAMPP

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

![Construction de l'image `bonus-web` et téléchargement de `mariadb` et `phpmyadmin`](docs/images/bonus-compose-up-debut.png)

*Construction de l'image `bonus-web` et téléchargement de `mariadb` et `phpmyadmin`*

![Réseau, volumes et 4 conteneurs créés](docs/images/bonus-compose-up-fin.png)

*Réseau, volumes et 4 conteneurs créés*

![`docker compose ps` : les 4 services en cours d'exécution](docs/images/bonus-compose-ps.png)

*`docker compose ps` : les 4 services en cours d'exécution*

### Tests

![`http://192.168.109.135` : PHP 8.3.35 et connexion à MariaDB réussie](docs/images/bonus-page-php.png)

*`http://192.168.109.135` : PHP 8.3.35 et connexion à MariaDB réussie*

![`http://192.168.109.135:8080` : phpMyAdmin connecté au serveur `db`, base `appdb` visible](docs/images/bonus-phpmyadmin.png)

*`http://192.168.109.135:8080` : phpMyAdmin connecté au serveur `db`, base `appdb` visible*

### Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| « MariaDB : ERREUR » juste après le démarrage | MariaDB met quelques secondes à s'initialiser au premier lancement | Attendre 10 secondes et recharger la page |

### À retenir

- Les services se joignent par leur nom (`db`) sur le réseau créé par compose : aucune adresse IP à connaître.
- Les données de la base sont dans un volume nommé : elles survivent à `docker compose down` (mais pas à `down -v`).

### Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./bonus-lamp/bonus.sh` (nettoyage : `./bonus-lamp/bonus.sh clean`). Le script ne fait que ce job.


---

---

## Scripts de démonstration (facultatifs)

La documentation ci-dessus décrit ce qui a été fait **à la main**. En complément, chaque job dispose d'un script indépendant, utile pour refaire une démonstration sur une machine vierge : il ne fait que ce job, sans enchaîner les autres.

```bash
git clone https://github.com/alexis-noiret/docker.git
cd docker
./job08/job08.sh          # exécute le job 08 seulement
./job08/job08.sh clean    # supprime ce que le job a créé
PAUSE=1 ./job08/job08.sh  # avec une pause entre les étapes, pour commenter
```

| Script | Rôle |
|---|---|
| `job01/job01.sh` | Installe Docker (désactive la source `cdrom`, dépôt officiel). `sudo` requis |
| `job02/job02.sh` ... `job09/job09.sh` | Un script par job : affiche chaque commande puis l'exécute |
| `job10/install-docker.sh`, `job10/uninstall-docker.sh` | Les deux scripts du job 10 (`sudo`) |
| `job11/job11.sh` | Déploie Portainer et prépare les archives `job03.tar`, `job04.tar`, `job08.tar` |
| `bonus-lamp/bonus.sh` | Déploie la stack du bonus |

Sur une machine sans Docker, les scripts des jobs 02 à 11 lancent d'abord `job01/job01.sh`. Juste après l'installation, l'utilisateur n'est pas encore dans le groupe `docker` : les scripts passent alors par `sudo docker` jusqu'à la prochaine connexion.

Ports utilisés : 80, 21 et 21000-21010 (job 7 et bonus, à ne pas lancer en même temps), 2222 (job 4), 8081 (job 8), 5000 et 8082 (job 9), 9443 (Portainer), 8080 (phpMyAdmin).

## Pense-bête soutenance : utiliser les scripts sur une VM vierge

Procédure testée sur une Debian 13 fraîchement installée (`debian-test`).

**1. Piège n°1 : `sudo` n'est pas installé sur une Debian vierge.** La première commande `sudo ...` échoue avec `sudo : commande introuvable`. Il faut l'installer une fois, en root :

```bash
su -                                  # mot de passe root
apt-get update && apt-get install -y sudo git
usermod -aG sudo alexis               # remplacer alexis par l'utilisateur
exit
```

Se **déconnecter puis se reconnecter** pour que le groupe `sudo` soit pris en compte, puis vérifier avec `sudo -v`.

*Alternative rapide :* rester en root (`su -`) pour toute la démonstration. Les scripts le gèrent : ils n'appellent `sudo` que si l'utilisateur n'est pas root.

**2. Récupérer le dépôt et lancer le job demandé** (toujours depuis la racine du dépôt, car les scripts utilisent `lib/common.sh`) :

```bash
git clone https://github.com/alexis-noiret/docker.git
cd docker
bash job08/job08.sh            # le job demandé, et lui seul
bash job08/job08.sh clean      # remettre à zéro avant un autre test
```

**3. Piège n°2 : le groupe `docker`.** Si Docker vient d'être installé par `job01.sh`, l'utilisateur n'est pas encore dans le groupe `docker` : se déconnecter/reconnecter, ou laisser les scripts passer par `sudo docker`. `job01.sh` doit être lancé avec `sudo bash job01/job01.sh`.

**4. Les deux scripts du job 10 :**

```bash
sudo bash job10/install-docker.sh
sudo bash job10/uninstall-docker.sh    # demande une confirmation : taper oui
```

**5. Autres points à garder en tête :**

| Situation | Réflexe |
|---|---|
| IP de la VM différente de `192.168.109.135` | Rien à faire : les scripts détectent l'IP de la VM (`hostname -I`). Utiliser cette IP dans FileZilla et le navigateur |
| Job 7 et bonus en même temps | Impossible (ports 80 et 21 communs) : `clean` de l'un avant l'autre |
| Port 5000 occupé (job 9) | Vérifier avec `ss -tlnp` |
| Portainer : « timeout » à la première connexion | `docker restart portainer`, puis créer le compte admin dans les 5 minutes |
| Docker absent sur la VM | Les scripts des jobs 02 à 11 lancent `job01.sh` d'eux-mêmes |

## Structure du dépôt

```
docker/
├── README.md              # cette documentation
├── docs/
│   ├── images/            # captures d'écran
│   └── Docker_soutenance.pdf / .pptx   # présentation
├── job01/ ... job09/      # un dossier par job : README, fichiers, script de démo
├── job10/                 # install-docker.sh, uninstall-docker.sh
├── job11/                 # Portainer
├── bonus-lamp/            # Dockerfile, docker-compose.yml, index.php
└── lib/common.sh          # fonctions communes aux scripts de démo
```

## Bilan et compétences

- **Administrer des infrastructures virtualisées** : installation de Docker sur Debian, gestion des images, conteneurs, volumes et réseaux.
- **Mettre en production des évolutions** : Dockerfile et docker compose pour décrire une infrastructure sous forme de fichiers reproductibles ; registry local pour distribuer les images.
- **Sécurité** : le socket Docker et le groupe `docker` donnent un accès root ; mots de passe de labo en clair, FTP non chiffré, registry sans authentification : points à durcir en production.
- **Automatisation** : alias, scripts d'installation et de désinstallation, scripts de démonstration.
