# Job 05 - Alias Docker dans ~/.bashrc

> **Consigne** : Tout informaticien étant « flemmard », faire des alias pour les commandes Docker en CLI, à mettre dans ~/.bashrc, pour manipuler les images et les conteneurs.

Les alias sont ajoutés à la fin de `~/.bashrc`, puis chargés avec `source ~/.bashrc`.

![Le bloc d'alias dans `~/.bashrc`](../docs/images/job05-alias-bashrc.png)

*Le bloc d'alias dans `~/.bashrc`*

```bash
source ~/.bashrc
alias | grep docker
dps          # docker ps
dpsa         # docker ps -a
di           # docker images
dex ssh-test bash   # docker exec -it ssh-test bash
```

![Liste des alias, puis utilisation de `dpsa`, `di` et `dex`](../docs/images/job05-alias-usage.png)

*Liste des alias, puis utilisation de `dpsa`, `di` et `dex`*

## À retenir

- Un alias n'existe que dans les shells interactifs qui lisent `~/.bashrc` : il ne fonctionne pas dans un script.
- `dstopall` et `drmall` utilisent `$(docker ps -q)` : pratiques mais destructeurs.

## Script de démonstration (optionnel)

Tout ce qui précède a été fait à la main. Pour rejouer ce job seul, par exemple en démonstration : `./job05/job05.sh` (nettoyage : `./job05/job05.sh clean`). Le script ne fait que ce job.

---
[Retour à la documentation générale](../README.md)
