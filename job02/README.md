# Job 02 - Tester l'installation : hello-world

> **Consigne** : Tester l'installation de Docker avec le conteneur « hello-world » et se familiariser avec les commandes.

```bash
docker run hello-world      # télécharge l'image, crée et lance le conteneur
docker ps                   # conteneurs en cours d'exécution
docker ps -a                # tous les conteneurs, y compris arrêtés
docker images               # images présentes en local
docker logs <conteneur>     # sortie d'un conteneur
docker rm <conteneur>       # supprimer un conteneur
docker rmi hello-world      # supprimer l'image (après le conteneur)
```

![`docker run hello-world` : l'image est téléchargée puis le message s'affiche](../docs/images/job02-hello-world.png)

*`docker run hello-world` : l'image est téléchargée puis le message s'affiche*

Le message décrit lui-même le fonctionnement : le client contacte le démon, le démon télécharge l'image depuis Docker Hub, crée un conteneur qui exécute le programme, puis renvoie la sortie au client. Le conteneur se termine aussitôt (`Exited (0)`).

## À retenir

- Image = modèle en lecture seule ; conteneur = instance de cette image.
- Un conteneur arrêté existe toujours (`docker ps -a`) tant qu'il n'est pas supprimé, et empêche de supprimer son image.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job02/job02.sh` (nettoyage : `./job02/job02.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
