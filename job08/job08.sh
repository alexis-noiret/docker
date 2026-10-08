#!/usr/bin/env bash
# Job 08 - nginx installé à la main dans une image Debian (sans image nginx officielle).
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/job08"; IMG=nginx-debian:job08; NAME=nginx-job08; PORT=8081

clean() {
  step "Nettoyage job 08"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker rmi "$IMG" >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
docker rm -f "$NAME" >/dev/null 2>&1 || true
title "Job 08 - nginx depuis un Dockerfile"

step "Le Dockerfile"
cmd cat "$DIR/Dockerfile"
pause

step "Construction de l'image"
cmd docker build -t "$IMG" "$DIR"
cmd docker images "$IMG"
pause

step "Lancement : port $PORT de la VM -> port 80 du conteneur"
cmd docker run -d --name "$NAME" -p "$PORT:80" "$IMG"
cmd docker ps --filter "name=$NAME"
pause

step "Connexion"
wait_http "http://localhost:$PORT" 30 || die "nginx ne répond pas sur le port $PORT"
cmd curl -s "http://localhost:$PORT"
info "Navigateur : http://$(host_ip):$PORT"
