#!/usr/bin/env bash
# Job 01 - Installer Docker (CLI seulement) sur Debian en mode console.
# Usage : sudo ./job01.sh          installe Docker
#         sudo ./job01.sh clean    désinstalle Docker (voir job10)
set -euo pipefail
if [ "${1:-}" = clean ]; then
  echo oui | bash "$(dirname "$0")/../job10/uninstall-docker.sh"
  exit 0
fi
[ "$EUID" -eq 0 ] || { echo "Ce script doit être lancé avec sudo." >&2; exit 1; }

APT="apt-get -o DPkg::Lock::Timeout=120"
. /etc/os-release
[ "${ID:-}" = debian ] || { echo "Ce script est prévu pour Debian (détecté : ${ID:-inconnu})." >&2; exit 1; }

echo "==> Désactivation de la source 'cdrom' (si présente)"
sed -i 's/^deb cdrom/# deb cdrom/' /etc/apt/sources.list

echo "==> Prérequis"
$APT update
$APT install -y ca-certificates curl gnupg

echo "==> Clé GPG et dépôt Docker (${VERSION_CODENAME})"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

echo "==> Installation des paquets Docker"
$APT update
$APT install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Démarrage du service"
systemctl enable --now docker

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
  usermod -aG docker "$SUDO_USER"
  echo "==> $SUDO_USER ajouté au groupe docker (reconnexion nécessaire pour en profiter)"
fi

echo "==> Test"
docker --version
docker compose version
docker run --rm hello-world >/dev/null && echo "Docker fonctionne."
