#!/usr/bin/env bash
# Job 04 - Image SSH construite à la main (root / root123), exposée sur le port 2222.
source "$(dirname "$0")/../lib/common.sh"
DIR="$ROOT/job04"; IMG=ssh-debian:job04; NAME=ssh-test; PORT=2222

clean() {
  step "Nettoyage job 04"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker rmi "$IMG" >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
docker rm -f "$NAME" >/dev/null 2>&1 || true
title "Job 04 - Serveur SSH dans un conteneur"

step "Le Dockerfile"
cmd cat "$DIR/Dockerfile"
pause

step "Construction de l'image"
cmd docker build -t "$IMG" "$DIR"
pause

step "Lancement : port 2222 de la VM -> port 22 du conteneur"
cmd docker run -d --name "$NAME" -p "$PORT:22" "$IMG"
cmd docker ps --filter "name=$NAME"

step "Test du port"
for _ in $(seq 1 20); do
  (exec 3<>"/dev/tcp/127.0.0.1/$PORT") 2>/dev/null && break
  sleep 1
done
banner=$(timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/$PORT; head -n1 <&3" || true)
info "Bannière SSH reçue : ${banner:-aucune}"
[ -n "$banner" ] || die "le serveur SSH ne répond pas sur le port $PORT"
pause

if [ -t 0 ]; then
  step "Connexion (mot de passe : root123 ; 'exit' pour quitter)"
  if command -v ssh >/dev/null 2>&1; then
    ssh -p "$PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$(host_ip)" || true
  else
    warn "client ssh absent : apt install openssh-client"
  fi
fi
info "Depuis un autre poste : ssh root@$(host_ip) -p $PORT"
