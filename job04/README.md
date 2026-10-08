# Job 04 - Dockerfile : une image SSH

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

![Le Dockerfile](../docs/images/job04-dockerfile.png)

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

![Build, lancement avec `2222->22`, puis connexion SSH au conteneur](../docs/images/job04-build-run-ssh.png)

*Build, lancement avec `2222->22`, puis connexion SSH au conteneur*

Test depuis la VM elle-même (le prompt `root@a372aaa732f9` est celui du conteneur) :

![`ssh root@localhost -p 2222` depuis la VM : on est dans le conteneur Debian](../docs/images/job04-ssh-localhost.png)

*`ssh root@localhost -p 2222` depuis la VM : on est dans le conteneur Debian*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| `ssh: Could not resolve hostname ip_vm` | J'avais recopié le texte `IP_VM` de l'exemple au lieu de l'adresse réelle | Utiliser l'IP de la VM : `192.168.109.135` |

## À retenir

- `EXPOSE` documente seulement ; c'est `-p` qui publie le port.
- Un conteneur n'a pas de systemd : un seul processus au premier plan.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job04/job04.sh` (nettoyage : `./job04/job04.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
