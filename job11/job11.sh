#!/usr/bin/env bash
# Job 11 - Déployer Portainer CE et préparer les archives pour le build via l'interface.
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/job11"

clean() {
  step "Nettoyage job 11"
  docker rm -f portainer >/dev/null 2>&1 || true
  docker volume rm portainer_data >/dev/null 2>&1 || true
  rm -rf "$DIR/archives"
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
title "Job 11 - Portainer"

step "Archives pour « Images > Build a new image > Upload »"
mkdir -p "$DIR/archives"
tar -C "$ROOT/job03" -cf "$DIR/archives/job03.tar" Dockerfile message.txt
tar -C "$ROOT/job04" -cf "$DIR/archives/job04.tar" Dockerfile
tar -C "$ROOT/job08" -cf "$DIR/archives/job08.tar" Dockerfile index.html
cmd ls -l "$DIR/archives"
pause

step "Déploiement de Portainer CE"
if docker ps -a --format '{{.Names}}' | grep -qx portainer; then
  info "Portainer existe déjà."
else
  cmd docker volume create portainer_data
  cmd docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:lts
fi
wait_http "https://localhost:9443" 60 || die "Portainer ne répond pas"
cmd docker ps --filter name=portainer

info "Interface : https://$(host_ip):9443 (certificat auto-signé)."
warn "Le compte administrateur doit être créé dans les 5 minutes, sinon : docker restart portainer"
warn "Archives à récupérer sur le PC : scp $(id -un)@$(host_ip):$DIR/archives/*.tar ~/"
