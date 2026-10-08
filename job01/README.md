# Job 01 - Installer Docker (CLI seulement)

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

![`systemctl status docker` : service actif (running) et enabled](../docs/images/job01-systemctl-status-docker.png)

*`systemctl status docker` : service actif (running) et enabled*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| apt demande le DVD d'installation | La ligne `deb cdrom` reste dans `/etc/apt/sources.list` après l'installation | La commenter avec `sed` |
| `permission denied` sur `/var/run/docker.sock` | L'utilisateur n'est pas dans le groupe `docker` | `usermod -aG docker $USER`, puis se déconnecter et se reconnecter |

## À retenir

- Docker = un démon (`dockerd`) + un client (`docker`) qui lui parle via un socket Unix.
- Appartenir au groupe `docker` équivaut à être root sur la machine.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job01/job01.sh` (nettoyage : `./job01/job01.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
