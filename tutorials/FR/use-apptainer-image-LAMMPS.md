# Comment utiliser l'image Apptainer de LAMMPS ?

En préalable de ces explications, il est nécessaire d'avoir installé Apptainer sur votre machine ; voir [ce lien](https://www.apptainer-images.diamond.fr/install-apptainer/FR) pour plus de détails.

Ce tutoriel détaille l'utilisation du l'image de conteneur du code LAMMPS téléchargeable à [cette adresse](https://www.apptainer-images.diamond.fr/lammps). En suivant ce lien, vous récupérez une image Apptainer (format de fichier `.sif`) qui vous permattra de créer des conteneurs à même de faire tourner LAMMPS.

Pour plus d'informations sur les conteneurs Apptainer, veuillez consulter la [page dédiée](https://www.apptainer-images.diamond.fr/apptainer-containers/FR)

Cette image est un fichier relocalisable et renommable, qu'il est recommandé de placer dans un répertoire dédié pour facilement la retrouver ; celui-ci peut-être quelconque, et dans le cadre de ce tutoriel nous assumerons que vous l'avez placé dans un répertoire nommé `$HOME/apptainer-images` :
```
mkdir -p $HOME/apptainer-images
mv ./lammps-mpi-voro++-from-guix.sif $HOME/apptainer-images/lammps.sif
```

## TL DR commande en une ligne

Pour les personnes pressées, voici comment lancer un calcul LAMMPS parallèle en utilisant l'image de conteneur (téléchargée au préalable et située à `$HOME/apptainer-images/lammps.sif`). Dans le cas où le répertoire courant contient les fichiers d'entrée nécessaires pour LAMMPS :
```
apptainer exec $HOME/apptainer-images/lammps.sif mpirun -np <N> lmp_mpi -in <input.lammps>
```

## Comment interagir avec l'image Apptainer

### Apptainer : cours accéléré

Cette section s'adresse aux personnes n'ayant pas encore utilisé Apptainer.

La principale manière d'interagir avec l'image se fait en invoquant la commande `apptainer` suivie de différents arguments :

* L'argument `run` permet de faire naître un conteneur à partir de l'image, d'invoquer la *commande par défaut de l'image* (c'est-à-dire ici un appel à l'exécutable `lmp_mpi`) dans le conteneur puis de détruire le conteneur.
```
$ apptainer run $HOME/apptainer-images/lammps.sif # exécute le binaire lmp_mpi dans le conteneur
```
Il est également possible de fournir des arguments à la commande par défaut en les ajoutant à la suite (ex. : `apptainer run $HOME/apptainer-images/lammps.sif -h`).

* L'argument `exec` est similaire à l'argument `run` mais d'invoquer n'importe quelle commande dans le conteneur. Par exemple :
```
$ apptainer exec $HOME/apptainer-images/lammps.sif pwd
```
crée un conteneur à partir de l'image `$HOME/apptainer-images/lammps.sif`, invoque la commande `pwd` dans le conteneur puis détruit le conteneur.

* l'argument `shell` permet d'ouvrir un shell interactif au sein du conteneur (le *prompt* `Apptainer>` apparaît alors à gauche de la ligne de commande) et d'y effectuer plusieurs commandes successives, puis d'en sortir en détruisant le conteneur avec `exit` ou `Crtl+D`. Par exemple :
```
$ apptainer shell $HOME/apptainer-images/lammps.sif
Apptainer> pwd
Apptainer> cd ..
Apptainer> pwd
Apptainer> lmp_mpi -h # fait apparaître le message d'aide de LAMMPS
Apptainer> exit
```

>[!Remarque]
>
> En jouant avec les arguments `exec` et `shell`, vous remarquerez que le nombre de commandes accessibles depuis le conteneur est très restreint. En effet, le conteneur se limite le plus possible aux outils nécessaires à l'exécution de LAMMPS, pour des raisons de portabilité (taille de l'image) et de sécurité.

* l'argument `run-help` permet d'afficher le message d'aide inclut dans l'image.
```
apptainer run-help $HOME/apptainer-images/lammps.sif
```

* l'argument `inspect` permet d'afficher les métadonnées relatives à l'image (propriétaire, auteur de l'image, version, date de création, ...)
```
apptainer inspect $HOME/apptainer-images/lammps.sif
```

Il est également possible d'exécuter l'image directement, comme un binaire :
```
$ $HOME/apptainer-images/lammps.sif
```
ce qui est strictement équivalent à `apptainer run $HOME/apptainer-images/lammps.sif`

### Utiliser le conteneur LAMMPS

L'image `$HOME/apptainer-images/lammps.sif` embarque une version de LAMMPS supportant la parallélisation via **OpenMP** et **MPI**.

Dans le cas où aucune conteneurisation ne serait utilisée, la commande typique ressemblerait à :
```
OMP_NUM_THREADS=2 mpirun -np 4 lmp_mpi -in in.file
```

En utilisant ce conteneur, la même commande devient
```
apptainer exec --env OMP_NUM_THREADS=2 $HOME/apptainer-images/lammps.sif mpirun -np 4 lmp_mpi -in in.file
```

>[!Remarque]
>
> Si rien n'est précisé, LAMMPS utilise par défaut un seul thread **OpenMP** `$OMP_NUM_THREADS=1` et répartit les processus **MPI** sur l'intégralité des cœurs disponibles.


### Isolation partielle ou isolation totale
Par défaut, Apptainer n'isole pas totalement le conteneur du système de la machine hôte. Les chemins suivants de la machine hôte sont montés et accessibles par défaut dans le conteneur : `$HOME`, `$PWD` `/sys`, `/proc`, `/tmp`, `/var/tmp`, `/etc/resolve.conf` et `/etc/passwd`.

Si l'on veut isoler le conteneur de la machine hôte, Apptainer propose différentes options (à adjoindre à `apptainer run`, `apptainer exec` ou `apptainer shell`) :

* l'utilisation du flag `--no-mount` pour délier un ou plusieurs chemins au sein du conteneur, par exemple
```
apptainer run --no-mount tmp,sys $HOME/apptainer-images/lammps.sif
```

* l'utilisation du flag `--no-home` rend le répertoire `$HOME` inaccessible au conteneur (mais `$PWD` reste monté) :
```
apptainer run --no-home $HOME/apptainer-images/lammps.sif
```

* le flag `--containall` isole totalement le conteneur de la machine hôte.
```
apptainer run --containall $HOME/apptainer-images/lammps.sif
```

Dans le cas où l'option `--containall` est activé, le répertoire contenant les fichiers d'entrée de LAMMPS n'est pas accessible dans le conteneur ! Il faut alors le monter manuellement avec le flag `--bind` au répertoire où l'on se trouve par défaut dans le conteneur (`$HOME`). Par exemple :
```
apptainer run --containall --bind $PWD:$HOME $HOME/apptainer-images/lammps.sif
```
dans le cas où les fichiers d'entrée de LAMMPS se situent dans le répertoire courant (`$PWD`).

## Exercices

>[!Exercice 1]
>
> Comment utiliser l'image de conteneur pour effectuer un calcul LAMMPS en séquentiel ?
> **Données**
> * L'image est située au chemin suivant : `$HOME/apptainer-images/lammps.sif`
> * Les fichiers d'entrée (dont le fichier d'entrée principal nommé `in.exercice`) sont situés dans le répertoire courant : `$PWD`
>
> Réponses possibles :
> `apptainer run $HOME/apptainer-images/lammps.sif -in in.exercice`
> ou `apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -in in.exercice`
> ou `$HOME/apptainer-images/lammps.sif -in in.exercice`
> ou
> ```
> apptainer exec \
>   --env OMP_NUM_THREADS=1 \
>   $HOME/apptainer-images/lammps.sif \
>   mpirun -np 1 lmp_mpi -in in.exercice
> ```


>[!Exercice 2]
>
> Comment utiliser l'image de conteneur pour effectuer un calcul LAMMPS (1 thread **OpenMP** et 16 cœurs **MPI**) ?
> **Données**
> * L'image est située au chemin suivant : `$HOME/apptainer-images/lammps.sif`
> * Les fichiers d'entrée (dont le fichier d'entrée principal nommé `in.exercice`) sont situés dans le répertoire courant : `$PWD`
>
> Exemple de réponse possible :
> ```
> apptainer exec \
>   $HOME/apptainer-images/lammps.sif \
>   mpirun -np 16 lmp_mpi -in in.exercice
> ```
> où l'option `--env OMP_NUM_THREADS=1` est implicite et que le conteneur utilise par défaut. 

>[!Exercice 3]
>
> Comment utiliser l'image de conteneur pour effectuer un calcul LAMMPS (2 threads **OpenMP** et 8 cœurs **MPI**) complètement isolé du système hôte ?
> **Données**
> * L'image est située au chemin suivant : `$HOME/apptainer-images/lammps.sif`
> * Les fichiers d'entrée (dont le fichier d'entrée principal nommé `in.exercice`) sont situés au chemin suivant : `$HOME/lammps-examples/exercice/`
>
> Exemple de réponse possible
> ```
> apptainer exec \
>   --containall \
>   --env OMP_NUM_THREADS=2 \
>   --bind $HOME/lammps-examples/exercice/=$HOME \
>   $HOME/apptainer-images/lammps.sif \
>   mpirun -np 8 lmp_mpi -in in.exercice
> ```