#!/bin/bash
# Supprime totalement Docker (conteneurs, images, volumes, paquets, config)

if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être lancé avec sudo."
    exit 1
fi

read -p "Cela supprime TOUT Docker (images, conteneurs, volumes). Continuer ? (oui/non) " rep
[ "$rep" = "oui" ] || { echo "Annulé."; exit 0; }

if command -v docker >/dev/null 2>&1; then
    echo "[1/5] Suppression des conteneurs, images, volumes et réseaux..."
    docker ps -aq | xargs -r docker rm -f
    docker volume ls -q | xargs -r docker volume rm
    docker system prune -af
fi

echo "[2/5] Arrêt des services..."
systemctl stop docker docker.socket containerd 2>/dev/null

echo "[3/5] Suppression des paquets..."
for p in docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
         docker-compose-plugin docker-ce-rootless-extras docker.io docker-compose; do
    if dpkg -l "$p" 2>/dev/null | grep -q '^ii'; then
        apt-get -o DPkg::Lock::Timeout=120 purge -y "$p"
    fi
done
apt-get -o DPkg::Lock::Timeout=120 autoremove -y --purge

echo "[4/5] Suppression des données et de la configuration..."
rm -rf /var/lib/docker /var/lib/containerd /etc/docker
rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.asc
groupdel docker 2>/dev/null

echo "[5/5] Mise à jour de l'index apt..."
apt-get update

echo "Docker est complètement supprimé."
