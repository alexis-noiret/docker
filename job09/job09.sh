#!/usr/bin/env bash
# Job 09 - Registry local (registry:2) + interface web (joxit/docker-registry-ui).
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/job09"; SRC=nginx-debian:job08; REMOTE=localhost:5000/nginx-debian:job08

clean() {
  step "Nettoyage job 09"
  docker compose -f "$DIR/docker-compose.yml" down -v >/dev/null 2>&1 || true
  docker rmi "$REMOTE" "$SRC" >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
title "Job 09 - Registry local et interface web"

step "Le fichier docker-compose.yml"
cmd cat "$DIR/docker-compose.yml"
pause

step "Démarrage du registry et de l'interface"
cmd docker compose -f "$DIR/docker-compose.yml" up -d
wait_http "http://localhost:5000/v2/" 60 || die "le registry ne répond pas"
cmd docker compose -f "$DIR/docker-compose.yml" ps
pause

step "Image à publier (celle du job 08, construite si absente)"
if ! docker image inspect "$SRC" >/dev/null 2>&1; then
  cmd docker build -t "$SRC" "$ROOT/job08"
fi

step "Tag + push vers le registry local"
cmd docker tag "$SRC" "$REMOTE"
cmd docker push "$REMOTE"
pause

step "Contenu du registry (API)"
cmd curl -s http://localhost:5000/v2/_catalog
echo
cmd curl -s http://localhost:5000/v2/nginx-debian/tags/list
echo
pause

step "Récupération depuis le registry : on supprime la copie locale puis on la retire"
cmd docker rmi "$REMOTE"
cmd docker pull "$REMOTE"
info "Interface web : http://$(host_ip):8082"
