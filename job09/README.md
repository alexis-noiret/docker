# Job 09 - Registry local et interface web

> **Consigne** : Créer et utiliser un « registry » local, et ajouter une « UI » pour le gérer depuis une interface web.

```yaml
services:
  registry:
    image: registry:2
    container_name: registry
    ports:
      - "5000:5000"
    environment:
      REGISTRY_STORAGE_DELETE_ENABLED: "true"
    volumes:
      - registry-data:/var/lib/registry

  registry-ui:
    image: joxit/docker-registry-ui:latest
    container_name: registry-ui
    ports:
      - "8082:80"
    environment:
      SINGLE_REGISTRY: "true"
      REGISTRY_TITLE: "Registry local"
      DELETE_IMAGES: "true"
      NGINX_PROXY_PASS_URL: "http://registry:5000"
    depends_on:
      - registry

volumes:
  registry-data:
```

![Le fichier `docker-compose.yml`](../docs/images/job09-compose.png)

*Le fichier `docker-compose.yml`*

`registry:2` est le registry officiel ; `joxit/docker-registry-ui` fournit l'interface et passe par un proxy interne (`NGINX_PROXY_PASS_URL`). Le nom d'une image contient l'adresse du registry : `localhost:5000/nginx-debian:v1`.

```bash
docker compose up -d
docker compose ps

docker tag nginx-debian localhost:5000/nginx-debian:v1
docker push localhost:5000/nginx-debian:v1
curl http://localhost:5000/v2/_catalog          # {"repositories":["nginx-debian"]}

docker rmi localhost:5000/nginx-debian:v1 nginx-debian    # on supprime la copie locale...
docker pull localhost:5000/nginx-debian:v1                # ...et on la récupère depuis le registry
```

![Démarrage des deux conteneurs, `tag`, `push`, `_catalog`, puis `rmi` et `pull`](../docs/images/job09-compose-up-push.png)

*Démarrage des deux conteneurs, `tag`, `push`, `_catalog`, puis `rmi` et `pull`*

![Interface web (`:8082`) : le dépôt `nginx-debian`](../docs/images/job09-registry-ui.png)

*Interface web (`:8082`) : le dépôt `nginx-debian`*

![Le tag `v1` (amd64, 33 Mo)](../docs/images/job09-registry-ui-tags.png)

*Le tag `v1` (amd64, 33 Mo)*

## À retenir

- Docker accepte `localhost:5000` en HTTP. Depuis une autre machine il faut TLS ou déclarer le registry dans `insecure-registries` (`/etc/docker/daemon.json`).
- Ce registry n'a pas d'authentification : à protéger hors laboratoire.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job09/job09.sh` (nettoyage : `./job09/job09.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
