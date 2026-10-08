#!/usr/bin/env bash
# Bonus - équivalent de XAMPP : Apache + PHP, MariaDB, phpMyAdmin, FTP, volume commun.
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/bonus-lamp"
export HOST_IP; HOST_IP="$(host_ip)"

clean() {
  step "Nettoyage bonus"
  docker compose -f "$DIR/docker-compose.yml" down -v --rmi local >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
title "Bonus - stack LAMP + FTP + phpMyAdmin"

step "Libération des ports 80 et 21 (stack du job 07 éventuellement active)"
docker rm -f web-nginx web-ftp >/dev/null 2>&1 || true

step "Dockerfile et docker-compose.yml"
cmd cat "$DIR/Dockerfile"
cmd cat "$DIR/docker-compose.yml"
pause

step "Construction et démarrage"
cmd docker compose -f "$DIR/docker-compose.yml" up -d --build
cmd docker compose -f "$DIR/docker-compose.yml" ps
pause

step "Droits d'écriture FTP puis envoi de index.php (même volume que le site)"
cmd docker exec bonus-ftp chown -R alexis /var/www/html
cmd curl -sS -T "$DIR/index.php" ftp://alexis:ftp123@localhost/
pause

step "Test PHP + MariaDB (attente de l'initialisation de la base)"
ok=0
for _ in $(seq 1 60); do
  if curl -s http://localhost | grep -q "connexion OK"; then ok=1; break; fi
  sleep 1
done
cmd curl -s http://localhost
echo
[ "$ok" = 1 ] || die "la connexion PHP -> MariaDB ne fonctionne pas"
info "Site : http://$HOST_IP"
info "phpMyAdmin : http://$HOST_IP:8080  (app / app123, base appdb)"
info "FTP : $HOST_IP port 21 (alexis / ftp123)"
