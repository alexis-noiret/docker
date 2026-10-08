#!/bin/bash
# Installe Docker (dépôt officiel) sur Debian
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être lancé avec sudo."
    exit 1
fi

echo "[1/5] Prérequis..."
apt-get update
apt-get install -y ca-certificates curl

echo "[2/5] Clé GPG de Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "[3/5] Dépôt Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

echo "[4/5] Installation de Docker..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

echo "[5/5] Ajout de l'utilisateur au groupe docker..."
if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG docker "$SUDO_USER"
    echo "Déconnecte-toi puis reconnecte-toi pour utiliser docker sans sudo."
fi

echo "Test..."
docker run --rm hello-world
echo "Docker est installé."
