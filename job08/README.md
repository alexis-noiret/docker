# Job 08 - Dockerfile : nginx sans image nginx

> **Consigne** : Sans utiliser d'image nginx existante, utiliser un Dockerfile pour créer un conteneur nginx, gérer la redirection de port et s'y connecter.

```dockerfile
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

COPY index.html /var/www/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

![`index.html` et Dockerfile](../docs/images/job08-index-dockerfile.png)

*`index.html` et Dockerfile*

```bash
docker build -t nginx-debian .
docker run -d --name nginx-test -p 8081:80 nginx-debian
docker ps
curl http://localhost:8081
```

![Build, lancement sur le port 8081 et `curl`](../docs/images/job08-build-run-curl.png)

*Build, lancement sur le port 8081 et `curl`*

![La page dans le navigateur : `http://192.168.109.135:8081`](../docs/images/job08-navigateur.png)

*La page dans le navigateur : `http://192.168.109.135:8081`*

Comparaison de taille avec l'image officielle (déjà utilisée au job 7) :

![`nginx-debian` : 132 Mo sur disque, contre 243 Mo pour `nginx:latest`](../docs/images/job08-images-ps.png)

*`nginx-debian` : 132 Mo sur disque, contre 243 Mo pour `nginx:latest`*

## Problèmes rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| Le conteneur s'arrêterait immédiatement | nginx se lance en démon (arrière-plan) par défaut, et Docker arrête le conteneur quand le processus principal se termine | `CMD ["nginx", "-g", "daemon off;"]` pour rester au premier plan |

## À retenir

- Port 8081 = côté VM ; port 80 = côté conteneur. Le port 80 de la VM est déjà pris par le job 7.
- `--no-install-recommends` et la suppression du cache apt dans le même `RUN` allègent l'image.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job08/job08.sh` (nettoyage : `./job08/job08.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
