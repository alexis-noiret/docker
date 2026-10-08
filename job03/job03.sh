#!/usr/bin/env bash
# Job 03 - Recréer « hello-world » avec un Dockerfile depuis une image Debian minimale.
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/job03"; IMG=hello-debian:job03

clean() {
  step "Nettoyage job 03"
  docker rmi "$IMG" >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
title "Job 03 - Dockerfile : recréer hello-world"

step "Le Dockerfile"
cmd cat "$DIR/Dockerfile"
pause

step "Le message à afficher = la vraie sortie de hello-world"
docker run --rm hello-world > "$DIR/message.txt"
cmd head -n 5 "$DIR/message.txt"
pause

step "Construction de l'image"
cmd docker build -t "$IMG" "$DIR"
cmd docker images "$IMG"
cmd docker history "$IMG"
pause

step "Lancement du conteneur"
cmd docker run --rm "$IMG"
pause

step "Comparaison avec l'original"
if diff <(docker run --rm hello-world) <(docker run --rm "$IMG") >/dev/null; then
  info "Sorties identiques."
else
  warn "Sorties différentes."
fi
