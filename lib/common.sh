#!/usr/bin/env bash
# Fonctions communes aux scripts de démo (chargé par chaque script de job).
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -t 1 ]; then
  C_B=$'\e[1;34m'; C_Y=$'\e[0;33m'; C_G=$'\e[0;32m'; C_R=$'\e[0;31m'; C_N=$'\e[0m'
else
  C_B=; C_Y=; C_G=; C_R=; C_N=
fi

title() { echo; echo "${C_B}==== $* ====${C_N}"; }
step()  { echo; echo "${C_B}==> $*${C_N}"; }
info()  { echo "${C_G}$*${C_N}"; }
warn()  { echo "${C_Y}$*${C_N}"; }
die()   { echo "${C_R}ERREUR : $*${C_N}" >&2; exit 1; }

# Affiche la commande puis l'exécute (pratique pour commenter à l'oral).
cmd()   { echo "${C_Y}\$ $*${C_N}"; "$@"; }

# Pause entre les étapes ; désactivée par défaut, activée avec PAUSE=1.
pause() {
  [ "${PAUSE:-0}" = 1 ] || return 0
  read -r -p "${C_G}[Entrée pour continuer]${C_N} " _ || true
}

host_ip() { hostname -I | awk '{print $1}'; }

as_root() { if [ "$EUID" -eq 0 ]; then "$@"; else sudo "$@"; fi; }

# Appelle docker directement, ou via sudo si l'utilisateur n'est pas (encore)
# dans le groupe docker (cas juste après l'installation, avant la reconnexion).
docker() {
  if [ "$EUID" -eq 0 ] || [ -w /var/run/docker.sock ]; then
    command docker "$@"
  else
    sudo docker "$@"
  fi
}

# Attend qu'une URL réponde (code HTTP < 400). Usage : wait_http URL [secondes]
wait_http() {
  local url=$1 max=${2:-60} i=0
  until curl -fsS -k -o /dev/null "$url" 2>/dev/null; do
    i=$((i + 1))
    [ "$i" -ge "$max" ] && return 1
    sleep 1
  done
}

# Vérifie (et installe si besoin) Docker et curl.
ensure_docker() {
  if ! command -v curl >/dev/null 2>&1; then
    as_root apt-get -o DPkg::Lock::Timeout=120 install -y curl
  fi
  if ! command -v docker >/dev/null 2>&1; then
    warn "Docker n'est pas installé : lancement de job01/job01.sh"
    as_root bash "$ROOT/job01/job01.sh"
  fi
  docker info >/dev/null 2>&1 || die "le démon Docker ne répond pas (systemctl status docker)"
}
