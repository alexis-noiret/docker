#!/usr/bin/env bash
# Job 07 - nginx + FTP liés par un volume commun (docker compose).
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/job07"
export HOST_IP; HOST_IP="$(host_ip)"

clean() {
  step "Nettoyage job 07"
  docker compose -f "$DIR/docker-compose.yml" down -v >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
title "Job 07 - nginx + FTP avec volume commun"

step "Le fichier docker-compose.yml"
cmd cat "$DIR/docker-compose.yml"
pause

step "Démarrage de la stack (IP de la VM : $HOST_IP)"
cmd docker compose -f "$DIR/docker-compose.yml" up -d
cmd docker compose -f "$DIR/docker-compose.yml" ps
pause

step "Droits : l'utilisateur FTP doit pouvoir écrire dans le volume"
cmd docker exec web-ftp chown -R alexis /usr/share/nginx/html

step "Page par défaut de nginx (avant l'envoi)"
wait_http "http://localhost" 30 || die "nginx ne répond pas"
curl -s http://localhost | grep -i "<title>"
pause

step "Envoi de index.html par FTP (équivalent en ligne de commande de FileZilla)"
info "FileZilla : hôte $HOST_IP - utilisateur alexis - mot de passe ftp123 - port 21"
cmd curl -sS -T "$DIR/index.html" ftp://alexis:ftp123@localhost/
pause

step "Résultat"
cmd curl -s http://localhost
info "Navigateur : http://$HOST_IP"
