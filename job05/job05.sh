#!/usr/bin/env bash
# Job 05 - Alias Docker dans ~/.bashrc (bloc délimité, donc idempotent).
source "$(dirname "$0")/../lib/common.sh"
USER_NAME="${SUDO_USER:-$(id -un)}"
BASHRC="$(getent passwd "$USER_NAME" | cut -d: -f6)/.bashrc"
BEGIN="# >>> docker aliases (job05) >>>"; END="# <<< docker aliases (job05) <<<"

remove_block() { [ -f "$BASHRC" ] && sed -i "\|$BEGIN|,\|$END|d" "$BASHRC" || true; }

clean() {
  step "Nettoyage job 05"
  remove_block
  info "Bloc d'alias retiré de $BASHRC"
}
if [ "${1:-}" = clean ]; then clean; exit 0; fi

title "Job 05 - Alias Docker"
step "Contenu des alias"
cmd cat "$ROOT/job05/docker-aliases.sh"
pause

step "Ajout dans $BASHRC"
touch "$BASHRC"
remove_block
{ echo "$BEGIN"; cat "$ROOT/job05/docker-aliases.sh"; echo "$END"; } >> "$BASHRC"
if [ "$(id -un)" != "$USER_NAME" ]; then chown "$USER_NAME": "$BASHRC"; fi
cmd grep -c "alias" "$BASHRC"
pause

step "Vérification dans un nouveau shell interactif"
cmd bash -ic 'alias | grep docker' 2>/dev/null
if command docker info >/dev/null 2>&1; then
  cmd bash -ic 'dps; di' 2>/dev/null
fi
info "Dans le terminal courant : source ~/.bashrc  (ou ouvrir un nouveau terminal)"
