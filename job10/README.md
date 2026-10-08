# Job 10 - Scripts d'installation et de désinstallation de Docker

> **Consigne** : Faire un script bash pour effacer totalement Docker (images, volumes, conteneurs et paquets correspondants) et rendre le système propre, et aussi un script pour automatiser l'installation de Docker sur une machine Debian.

Deux scripts : [`uninstall-docker.sh`](job10/uninstall-docker.sh) et [`install-docker.sh`](job10/install-docker.sh).

## uninstall-docker.sh

![Le script de désinstallation](../docs/images/job10-cat-uninstall.png)

*Le script de désinstallation*

1. Vérifie qu'il est lancé en root et demande confirmation (`oui`).
2. Supprime conteneurs, volumes, réseaux et images (`xargs -r` évite d'appeler la commande sans argument).
3. Arrête `docker`, `docker.socket` et `containerd`.
4. Purge chaque paquet Docker installé (`dpkg -l`), puis `autoremove --purge`.
5. Supprime `/var/lib/docker`, `/var/lib/containerd`, `/etc/docker`, le dépôt et la clé GPG, et le groupe `docker`.

![Exécution : confirmation, arrêt des services, purge des paquets](../docs/images/job10-uninstall-1.png)

*Exécution : confirmation, arrêt des services, purge des paquets*

![Fin de l'exécution : « Docker est complètement supprimé. »](../docs/images/job10-uninstall-2.png)

*Fin de l'exécution : « Docker est complètement supprimé. »*

## install-docker.sh

![Le script d'installation](../docs/images/job10-cat-install.png)

*Le script d'installation*

Il reprend la procédure du job 1 en 5 étapes numérotées, avec `set -e` pour s'arrêter à la première erreur, et se termine par un test `hello-world`.

![Exécution : prérequis, clé GPG, dépôt, installation](../docs/images/job10-install-debut.png)

*Exécution : prérequis, clé GPG, dépôt, installation*

![Fin : `hello-world`, « Docker est installé. », puis `docker --version` et `docker compose version`](../docs/images/job10-install-fin.png)

*Fin : `hello-world`, « Docker est installé. », puis `docker --version` et `docker compose version`*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| `apt` échoue : verrou `dpkg` déjà pris | Un autre processus apt (mise à jour automatique) tenait le verrou pendant la désinstallation | `apt-get -o DPkg::Lock::Timeout=120` : apt attend jusqu'à 2 minutes au lieu d'échouer |

## À retenir

- `purge` supprime aussi les fichiers de configuration, contrairement à `remove`.
- Limite connue : `uninstall-docker.sh` n'a pas de `set -e` et affiche « complètement supprimé » sans contrôler le résultat d'apt. Amélioration possible : `set -e` et une vérification finale (`command -v docker`, `dpkg -l`).

---
[Retour à la documentation générale](../README.md)
