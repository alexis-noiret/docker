# Job 03 - Dockerfile : recréer hello-world depuis une image Debian

> **Consigne** : Utiliser un Dockerfile pour recréer le conteneur « hello-world » depuis une image Debian minimale.

L'objectif est que mon image Debian affiche **exactement le même message** que `hello-world`. Je récupère donc la vraie sortie de `hello-world` dans un fichier, que je copie dans l'image.

```bash
mkdir -p ~/docker/job03 && cd ~/docker/job03
docker run --rm hello-world > message.txt

cat > Dockerfile <<'EOF'
FROM debian:stable-slim
COPY message.txt /message.txt
CMD ["cat", "/message.txt"]
EOF

docker build -t hello-debian .
docker run --rm hello-debian
```

![Le Dockerfile](../docs/images/job03-dockerfile.png)

*Le Dockerfile*

![Construction de l'image `hello-debian`](../docs/images/job03-build.png)

*Construction de l'image `hello-debian`*

Comparaison des deux sorties avec `diff` : elles sont identiques.

```bash
diff <(docker run --rm hello-debian) <(docker run --rm hello-world) && echo "Identique"
```

![Les deux sorties sont identiques](../docs/images/job03-diff-identique.png)

*Les deux sorties sont identiques*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Première version : message personnalisé au lieu du vrai message | Le sujet demande de recréer `hello-world`, pas d'afficher un texte libre | Reprendre la sortie réelle de `hello-world` et vérifier avec `diff` |

## À retenir

- `FROM` choisit l'image de base, `COPY` ajoute un fichier (nouvelle couche), `CMD` est la commande lancée au démarrage.
- `docker history hello-debian` montre les couches de l'image.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job03/job03.sh` (nettoyage : `./job03/job03.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
