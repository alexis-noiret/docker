#!/usr/bin/env bash
# Job 02 - Tester l'installation avec hello-world et découvrir les commandes.
source "$(dirname "$0")/../lib/common.sh"

clean() {
  step "Nettoyage job 02"
  docker rm -f hello-test >/dev/null 2>&1 || true
  docker rmi hello-world >/dev/null 2>&1 || true
  info "ok"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

ensure_docker
docker rm -f hello-test >/dev/null 2>&1 || true

title "Job 02 - hello-world et commandes de base"
step "Versions"
cmd docker --version
cmd docker version
pause

step "Premier conteneur : hello-world (--rm : supprimé dès qu'il se termine)"
cmd docker run --rm hello-world
pause

step "Même image, conteneur nommé et conservé"
cmd docker run --name hello-test hello-world
cmd docker ps
cmd docker ps -a
cmd docker images
cmd docker inspect --format 'état={{.State.Status}} code_retour={{.State.ExitCode}}' hello-test
pause

step "Autres commandes utiles : pull, run, logs"
cmd docker pull debian:stable-slim
cmd docker run --rm debian:stable-slim cat /etc/os-release
cmd docker logs hello-test
pause

info "Le conteneur hello-test et l'image hello-world sont conservés."
info "Pour les supprimer : ./job02/job02.sh clean"
