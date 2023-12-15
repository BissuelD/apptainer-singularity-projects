# Comment utiliser l'image Apptainer de LAMMPS ?

En préalable de ces explications, il est nécessaire d'avoir installé Apptainer sur votre machine ; voir [ce lien](https://www.apptainer-images.diamond.fr/install-apptainer/FR) pour plus de détails.

Ce tutoriel détaille l'utilisation du l'image de conteneur du code LAMMPS téléchargeable à [cette adresse](https://www.apptainer-images.diamond.fr/lammps). En suivant ce lien, vous récupérez une image Apptainer (format de fichier `.sif`) qui vous permattra de créer des conteneurs à même de faire tourner LAMMPS.

Pour plus d'informations sur les conteneurs Apptainer, veuillez consulter la [page dédiée](https://www.apptainer-images.diamond.fr/apptainer-containers/FR).

Pour rapidement s'approprier les principales commandes d'Apptainer, vous pouvez vous référer à [ce tutoriel](https://www.apptainer-images.diamond.fr/apptainer-tutorial/FR).

Cette image est un fichier relocalisable et renommable, qu'il est recommandé de placer dans un répertoire dédié pour facilement la retrouver ; celui-ci peut-être quelconque, et dans le cadre de ce tutoriel nous assumerons que vous l'avez placée dans un répertoire nommé `$HOME/apptainer-images` :
```
mkdir -p $HOME/apptainer-images
mv lammps.sif $HOME/apptainer-images/lammps.sif
```

## TL; DR Commande en une ligne
Pour les personnes pressées, voici comment lancer un calcul LAMMPS parallèle en utilisant l'image de conteneur (téléchargée au préalable et située à `$HOME/apptainer-images/lammps.sif`). Dans le cas où le répertoire courant contient les fichiers d'entrée nécessaires pour LAMMPS :
```
apptainer exec $HOME/apptainer-images/lammps.sif mpirun -np <N> lmp_mpi -in <input.lammps>
```

## Détail d'utilisation du conteneur LAMMPS
Cette section présente les différentes manières d'utiliser l'image LAMMPS. Pour plus de détails sur les commandes Apptainer, veuillez vous référer à [ce tutoriel](https://www.apptainer-images.diamond.fr/apptainer-tutorial%basic-commands/FR).

### Utiliser le conteneur LAMMPS en séquentiel
Pour exécuter LAMMPS en séquentiel (c'est-à-dire sans parallélisation) sans conteneur, on utiliserait la commande :
```
lmp_mpi -in in.file
```
où tous les fichiers d'entrée LAMMPS (dont `in.file` le fichier d'entrée principal) sont stockés dans le répertoire courant.

Pour effectuer la même chose dans un conteneur, on peut exécuter trois commandes équivalentes. Dans chacun des exemples suivants, on suppose que l'image Apptainer `lammps.sif` est stockée sous `$HOME/apptainer-images/lammps.sif`.

* On peut utiliser `apptainer exec` qui permet d'exécuter une commande spécifique dans le conteneur.
```
apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -in in.file
```

* On peut utiliser `apptainer run` qui appelle la commande par défaut du conteneur, à savoir l'exécutable `lmp_mpi`, en lui spécifiant à la suite les instructions permettant à LAMMPS de localiser le fichier d'entrée.
```
apptainer run $HOME/apptainer-images/lammps.sif -in in.file # "lmp_mpi" est implicitement appelé par "run"
```

* On peut enfin appeler directement l'image comme un exécutable, ce qui est strictement identique à l'utilisation de `apptainer run`.
```
$HOME/apptainer-images/lammps.sif -in in.file
```

### Utiliser le conteneur LAMMPS en parallèle
L'image `lammps.sif` embarque une version de LAMMPS supportant la parallélisation via **OpenMP** et **MPI**.

Dans le cas où aucune conteneurisation ne serait utilisée, la commande typique ressemblerait à :
```
OMP_NUM_THREADS=2 mpirun -np 4 lmp_mpi -in in.file
```

En utilisant ce conteneur, la même commande devient :
```
apptainer exec --env OMP_NUM_THREADS=2 $HOME/apptainer-images/lammps.sif mpirun -np 4 lmp_mpi -in in.file
```

**Remarque**
> Si rien n'est précisé, LAMMPS utilise par défaut un seul thread **OpenMP** (`$OMP_NUM_THREADS=1`) et répartit les processus **MPI** sur l'intégralité des cœurs disponibles.

### Afficher l'aide
Pour afficher le message d'aide du conteneur (on suppose l'image stockée sous `$HOME/apptainer-images/lammps.sif`) :
```
apptainer run-help $HOME/apptainer-images/lammps.sif
```

Pour afficher les méta-données du conteneur (propriétaire du code, version, auteur de l'image, ...) :
```
apptainer inspect $HOME/apptainer-images/lammps.sif
```

Pour lancer la commande d'aide spécifique à l'exécutable LAMMPS du conteneur (`lmp_mpi`) :
```
apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -h
```
ou
```
apptainer run $HOME/apptainer-images/lammps.sif -h
```
ou
```
$HOME/apptainer-images/lammps.sif -h
```

### Isolation partielle ou isolation totale
Par défaut, Apptainer n'isole pas totalement le conteneur du système de la machine hôte ; pour une isolation partielle ou totale, il faut utiliser respectivement les flags `--no-mount` ou `--no-home` et `--contain-all` (voir [ce lien](https://www.apptainer-images.diamond.fr/apptainer-tutorial%isolation/FR) pour plus d'informations).

Dans le cas où l'option `--containall` est activée, le répertoire contenant les fichiers d'entrée de LAMMPS n'est pas accessible dans le conteneur !
```
apptainer run --containall $HOME/apptainer-images/lammps.sif -in in.file # in.file non trouvé !
```
Il faut alors monter manuellement le répertoire courant (`$PWD`) avec le flag `--bind` au répertoire où l'on se trouve par défaut dans le conteneur (`$HOME`). Par exemple :
```
apptainer run --containall --bind $PWD:$HOME \ # On monte le répertoire courant au $HOME du conteneur.
  $HOME/apptainer-images/lammps.sif -in in.file
```
dans le cas où les fichiers d'entrée de LAMMPS se situent dans le répertoire courant (`$PWD`).

## Exercices

### Exercice 1
Comment utiliser l'image de conteneur pour effectuer un calcul LAMMPS en séquentiel ?

> **Données**
> * L'image est située au chemin suivant : `$HOME/apptainer-images/lammps.sif`
> * Les fichiers d'entrée (dont le fichier d'entrée principal nommé `in.exercice`) sont situés dans le répertoire courant : `$PWD`

Réponses possibles :
* `apptainer run $HOME/apptainer-images/lammps.sif -in in.exercice`
* ou `apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -in in.exercice`
* ou `$HOME/apptainer-images/lammps.sif -in in.exercice`
* ou
```
apptainer exec \
  --env OMP_NUM_THREADS=1 \
  $HOME/apptainer-images/lammps.sif \
  mpirun -np 1 lmp_mpi -in in.exercice
```


### Exercice 2
Comment utiliser l'image de conteneur pour effectuer un calcul LAMMPS (1 thread **OpenMP** et 16 cœurs **MPI**) ?

**Données**
> * L'image est située au chemin suivant : `$HOME/apptainer-images/lammps.sif`
> * Les fichiers d'entrée (dont le fichier d'entrée principal nommé `in.exercice`) sont situés dans le répertoire courant : `$PWD`

Exemple de réponse possible :
```
apptainer exec \
  $HOME/apptainer-images/lammps.sif \
  mpirun -np 16 lmp_mpi -in in.exercice
```
où l'option `--env OMP_NUM_THREADS=1` est implicite et que le conteneur utilise par défaut. 

### Exercice 3
Comment utiliser l'image de conteneur pour effectuer un calcul LAMMPS (2 threads **OpenMP** et 8 cœurs **MPI**) complètement isolé du système hôte ?

**Données**
> * L'image est située au chemin suivant : `$HOME/apptainer-images/lammps.sif`
> * Les fichiers d'entrée (dont le fichier d'entrée principal nommé `in.exercice`) sont situés au chemin suivant : `$HOME/lammps-examples/exercice/`

Exemple de réponse possible
```
apptainer exec \
  --containall \
  --env OMP_NUM_THREADS=2 \
  --bind $HOME/lammps-examples/exercice/=$HOME \
  $HOME/apptainer-images/lammps.sif \
  mpirun -np 8 lmp_mpi -in in.exercice
```