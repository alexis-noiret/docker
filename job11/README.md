# Job 11 - Portainer

> **Consigne** : Découvrir Portainer. Refaire les jobs 2 à 9 en utilisant l'interface graphique de Portainer. Se renseigner sur les alternatives à Portainer.

## Installation de Portainer CE

```bash
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```

![Installation de Portainer CE (2.45.2 LTS)](../docs/images/job11-portainer-install.png)

*Installation de Portainer CE (2.45.2 LTS)*

Interface : `https://192.168.109.135:9443` (certificat auto-signé). Le compte administrateur doit être créé dans les **5 minutes** qui suivent le démarrage ; au-delà, Portainer se verrouille : `docker restart portainer`. Il faut ensuite cliquer sur l'environnement **local** pour voir les menus Containers, Images et Volumes.

`/var/run/docker.sock` est monté dans le conteneur : Portainer contrôle ainsi le démon Docker de l'hôte, ce qui équivaut à un accès root. Le compte administrateur doit donc être protégé.

## Job 2 - hello-world
`Containers > Add container`, image `hello-world`, `Deploy the container`, puis l'icône **Logs**.

![Logs des conteneurs `hello-world` (à gauche) et `hello-debian-test` (à droite)](../docs/images/job11-job02-logs.png)

*Logs des conteneurs `hello-world` (à gauche) et `hello-debian-test` (à droite)*

## Job 3 - image depuis un Dockerfile
Portainer construit une image depuis une archive : `Images > Build a new image > Upload`. Le Dockerfile doit être à la racine de l'archive.

```bash
cd ~/docker/job03
tar -cf job03.tar Dockerfile message.txt
tar -tf job03.tar
# récupération sur le PC : scp alexis@192.168.109.135:~/docker/job03/job03.tar ~/
```

![Sortie du build : `Successfully tagged hello-debian:latest`](../docs/images/job11-job03-build-sortie.png)

*Sortie du build : `Successfully tagged hello-debian:latest`*

## Job 4 - image SSH
Build avec le **Web editor** (le Dockerfile est collé dans l'interface), puis conteneur `ssh-test` avec le port `2222` vers `22`.

![Build de `ssh-debian` avec le Web editor](../docs/images/job11-job04-build-web-editor.png)

*Build de `ssh-debian` avec le Web editor*

![Détail du conteneur `ssh-test`](../docs/images/job11-job04-ssh-test-details.png)

*Détail du conteneur `ssh-test`*

![Liste des conteneurs : `ssh-test` publie `2222:22`](../docs/images/job11-job04-conteneurs.png)

*Liste des conteneurs : `ssh-test` publie `2222:22`*

## Job 5 - alias
Pas d'équivalent dans Portainer : un alias est un raccourci du shell.

### Job 6 - volumes
`Volumes > Add volume`, puis deux conteneurs `c1` et `c2` qui montent le même volume (`Advanced container settings > Volumes`). La console (icône `>_`) permet de vérifier : `c2` lit le fichier écrit par `c1`.

![Conteneurs `c1` et `c2`](../docs/images/job11-job06-conteneurs.png)

*Conteneurs `c1` et `c2`*

![Console de `c2` : `cat /data/test.txt` affiche « depuis c1 »](../docs/images/job11-job06-console-c2.png)

*Console de `c2` : `cat /data/test.txt` affiche « depuis c1 »*

## Job 7 - nginx + FTP
`Stacks > Add stack`, nom `job07`, le YAML du job 7 collé dans le Web editor, `Deploy the stack`. Le `chown` se fait dans la console du conteneur `web-ftp`.

![Stack `job07` : `web-ftp` et `web-nginx` en cours d'exécution](../docs/images/job11-job07-stack.png)

*Stack `job07` : `web-ftp` et `web-nginx` en cours d'exécution*

![Console de `web-ftp` : `chown -R alexis /usr/share/nginx/html`](../docs/images/job11-job07-chown-console.png)

*Console de `web-ftp` : `chown -R alexis /usr/share/nginx/html`*

## Job 8 - nginx depuis un Dockerfile
Build de l'archive `job08.tar` (`Dockerfile` + `index.html`), puis conteneur `nginx-job08` avec le port `8081` vers `80`. L'option **« Always pull the image »** doit être **désactivée** : l'image `nginx-debian:job08` n'existe qu'en local.

![Sortie du build : `Successfully tagged nginx-debian:job08`](../docs/images/job11-job08-build-sortie.png)

*Sortie du build : `Successfully tagged nginx-debian:job08`*

![`nginx-job08` publie `8081:80` ; la stack `job07` tourne toujours](../docs/images/job11-job08-conteneurs.png)

*`nginx-job08` publie `8081:80` ; la stack `job07` tourne toujours*

## Job 9 - registry
Stack `job09` avec le YAML du job 9, puis `Registries > Add registry > Custom registry` pour déclarer `192.168.109.135:5000`.

![Création de la stack `job09`](../docs/images/job11-job09-stack.png)

*Création de la stack `job09`*

![`tag` et `push` dans le terminal ; `registry` et `registry-ui` apparaissent dans Portainer](../docs/images/job11-job09-tag-push.png)

*`tag` et `push` dans le terminal ; `registry` et `registry-ui` apparaissent dans Portainer*

![Interface du registry (tag `job08`) et registry `registry-local` ajouté dans Portainer](../docs/images/job11-job09-registry-local.png)

*Interface du registry (tag `job08`) et registry `registry-local` ajouté dans Portainer*

## Alternatives à Portainer
| Outil | Type | Points clés | Limites |
|---|---|---|---|
| **Dockge** | Interface web | Centré sur les stacks Compose, éditeur YAML, terminal web, multi-hôte par agents. Les `compose.yaml` restent sur le disque. Licence MIT, environ 50 Mo de RAM contre environ 200 Mo pour Portainer | Pas de Kubernetes ni de Swarm ; gestion limitée des conteneurs hors Compose |
| **Yacht** | Interface web | Modèles d'applications, gestion basique des conteneurs | Abandonné : aucune mise à jour depuis janvier 2023, versions alpha uniquement |
| **Lazydocker** | Terminal (TUI) | Un seul binaire, conteneurs, logs et stats dans le terminal | Pas d'interface graphique ni multi-utilisateur |
| **Cockpit** | Administration système | Gère tout le serveur, avec un module conteneurs | Module conteneurs surtout orienté Podman |
| **Rancher** | Plateforme | Gestion de clusters Kubernetes | Surdimensionné pour un seul hôte Docker |

Dockge convient pour un hôte unique centré sur Docker Compose. Portainer reste plus complet (images, volumes, réseaux, registries, multi-hôte, Kubernetes), mais RBAC, SSO et audit sont réservés à l'édition Business payante. Dockge, Yacht et Portainer montent tous le socket Docker et partagent donc le même risque.

Sources : [ossalt.com](https://ossalt.com/guides/portainer-vs-yacht-vs-dockge-2026), [selfhosting.sh (Yacht)](https://selfhosting.sh/apps/yacht/), [README de Dockge](https://raw.githubusercontent.com/louislam/dockge/master/README.md).

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Page de setup « expirée » ou menus absents | Portainer se verrouille 5 minutes après son démarrage ; les menus n'apparaissent qu'une fois l'environnement `local` sélectionné | `docker restart portainer`, créer le compte, puis cliquer sur `local` |
| Le conteneur du job 8 ne démarre pas | « Always pull the image » cherchait `nginx-debian` sur Docker Hub | Désactiver l'option (image locale) |
| Bouton `Deploy` grisé | Une ligne de port vide dans le formulaire | Supprimer la ligne vide |

## À retenir

- Docker Hub limite les téléchargements anonymes (100 pulls / 6 h) : visible dans Portainer, section Registries.
- Portainer facilite la visibilité (logs, inspect, console), mais une stack ou un script restent plus reproductibles.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job11/job11.sh` (nettoyage : `./job11/job11.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
