#!/usr/bin/env bash
# Job 06 - Volumes : partage entre deux conteneurs, bind mount, tmpfs.
source "$(dirname "$0")/../lib/common.sh"
VOL=vol-demo; BIND=/tmp/bind-demo; IMG=debian:stable-slim

clean() {
  step "Nettoyage job 06"
  docker rm -f c1 c2 c3 >/dev/null 2>&1 || true
  docker volume rm "$VOL" >/dev/null 2>&1 || true
  rm -rf "$BIND"
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
clean >/dev/null
title "Job 06 - Volumes"

step "1. Volume nommé partagé entre c1 et c2"
cmd docker volume create "$VOL"
cmd docker run -d --name c1 -v "$VOL:/data" "$IMG" sleep 3600
cmd docker run -d --name c2 -v "$VOL:/data" "$IMG" sleep 3600
cmd docker exec c1 sh -c 'echo "écrit par c1" > /data/message.txt'
cmd docker exec c2 cat /data/message.txt
cmd docker exec c2 sh -c 'echo "répondu par c2" >> /data/message.txt'
cmd docker exec c1 cat /data/message.txt
pause

step "2. Gestion des volumes : ls, inspect"
cmd docker volume ls
cmd docker volume inspect "$VOL"
pause

step "3. Persistance : on supprime c1 et c2, le volume reste"
cmd docker rm -f c1 c2
cmd docker volume ls
cmd docker run --rm --name c3 -v "$VOL:/data" "$IMG" cat /data/message.txt
pause

step "4. Bind mount : un dossier de la VM monté dans le conteneur"
mkdir -p "$BIND"
cmd docker run --rm -v "$BIND:/data" "$IMG" sh -c 'echo "créé dans le conteneur" > /data/fichier.txt'
cmd cat "$BIND/fichier.txt"
pause

step "5. tmpfs : en mémoire, disparaît avec le conteneur"
cmd docker run --rm --tmpfs /data "$IMG" sh -c 'echo test > /data/f.txt && df -h /data | tail -n 1'
pause

step "6. Suppression du volume"
cmd docker volume rm "$VOL"
cmd docker volume ls
info "docker volume prune supprime tous les volumes inutilisés."
rm -rf "$BIND"
