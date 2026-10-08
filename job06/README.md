# Job 06 - Volumes entre deux conteneurs

> **Consigne** : Se renseigner sur l'utilisation de volumes entre deux conteneurs et sur la gestion des volumes.

| Type | Syntaxe | Où sont les données | Usage |
|---|---|---|---|
| Volume nommé | `-v mon-volume:/data` | Géré par Docker (`/var/lib/docker/volumes`) | Données à conserver, partage entre conteneurs |
| Bind mount | `-v /chemin/hote:/data` | Un dossier de la machine hôte | Développement, configuration |
| tmpfs | `--tmpfs /data` | En mémoire, perdu à l'arrêt | Données temporaires ou sensibles |

Démonstration : deux conteneurs `c1` et `c2` montent le **même volume**. Ce que `c1` écrit, `c2` le lit.

```bash
docker volume create mon-volume
docker volume ls
docker volume inspect mon-volume

docker run --rm -v mon-volume:/data debian bash -c "echo 'bonjour' > /data/test.txt"
docker run --rm -v mon-volume:/data debian cat /data/test.txt     # le fichier a survécu au conteneur

docker run -d --name c1 -v mon-volume:/data debian sleep 3600
docker run -d --name c2 -v mon-volume:/data debian sleep 3600
docker exec c1 bash -c "echo 'depuis c1' >> /data/test.txt"
docker exec c2 cat /data/test.txt                                  # c2 voit « bonjour » et « depuis c1 »

docker rm -f c1 c2
docker volume rm mon-volume
docker volume prune
```

![Création, inspection, partage entre `c1` et `c2`, puis suppression](../docs/images/job06-volumes-cli.png)

*Création, inspection, partage entre `c1` et `c2`, puis suppression*

## À retenir

- Le volume survit à la suppression des conteneurs : c'est ce qui conserve une base de données.
- `docker volume inspect` donne le `Mountpoint` réel sur la VM (`/var/lib/docker/volumes/mon-volume/_data`).
- Deux conteneurs qui écrivent en même temps dans le même fichier peuvent se gêner : Docker ne pose pas de verrou.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job06/job06.sh` (nettoyage : `./job06/job06.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
