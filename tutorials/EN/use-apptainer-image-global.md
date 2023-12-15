# Comment utiliser l'image Apptainer de LAMMPS ?

En préalable de ces explications, il est nécessaire d'avoir installé Apptainer sur votre machine ; voir [ce lien](https://www.apptainer-images.diamond.fr/install-apptainer/FR) pour plus de détails.

Ce tutoriel détaille l'utilisation du l'image de conteneur du code LAMMPS téléchargeable à [cette adresse](https://www.apptainer-images.diamond.fr/lammps). En suivant ce lien, vous récupérez une image Apptainer (format de fichier `.sif`) qui vous permattra de créer des conteneurs à même de faire tourner LAMMPS.

Pour plus d'informations sur les conteneurs Apptainer, veuillez consulter la [page dédiée](https://www.apptainer-images.diamond.fr/apptainer-containers/FR)

Cette image est un fichier relocalisable et renommable, qu'il est recommandé de placer dans un répertoire dédié pour facilement la retrouver ; celui-ci peut-être quelconque, et dans le cadre de ce tutoriel nous assumerons que vous l'avez placée dans un répertoire nommé `$HOME/apptainer-images` :
```
mkdir -p $HOME/apptainer-images
mv ./lammps-mpi-voro++-from-guix.sif $HOME/apptainer-images/lammps.sif
```

## TL; DR Commande en une ligne
Pour les personnes pressées, voici comment lancer un calcul LAMMPS parallèle en utilisant l'image de conteneur (téléchargée au préalable et située à `$HOME/apptainer-images/lammps.sif`). Dans le cas où le répertoire courant contient les fichiers d'entrée nécessaires pour LAMMPS :
```
apptainer exec $HOME/apptainer-images/lammps.sif mpirun -np <N> lmp_mpi -in <input.lammps>
```

## Comment interagir avec l'image Apptainer


### Apptainer : crash course
This section is aimed for people who have not used Apptainer yet.

The main way to interact with the image is through invoking the `apptainer` command, followed by different arguments :

* The `run` argument spawns a container from the image, runs the *container's default commannd* (here calling the `lmp_mpi` executable) within the container, and then destroys it.
```
$ apptainer run $HOME/apptainer-images/lammps.sif # exécute le binaire lmp_mpi dans le conteneur
```
You may also provide supplementary arguments to the default command by appending them at the end (*eg.* : `apptainer run $HOME/apptainer-images/lammps.sif -h`).

* The `exec` argument is similar to the `run` argument, only invoking **any** specified command inside the container. For example :
```
$ apptainer exec $HOME/apptainer-images/lammps.sif sh -c
```
creates a container from the `$HOME/apptainer-images/lammps.sif` image, invokes the shell `pwd` command within the container, and then destroys it.

* The `shell` argument allows to enter an interactive shell inside the container (the `Apptainer>` *prompt* then appears on the left of the command line), run successive commands, then exit the container using `exit` or `Crtl+D`, which also destroys it. For example :
```
$ apptainer shell $HOME/apptainer-images/lammps.sif
Apptainer> pwd
Apptainer> cd ..
Apptainer> pwd
Apptainer> lmp_mpi -h # displays LAMMPS help message
Apptainer> exit
```

**Remark**
> Playing with `exec` et `shell` you'll notice only a quite limited amount of commands are available from the container. In fact, commands intend to be as restricted as possible to the ones needed to run LAMMPS, both for portability (image size) and security reasons.

* The `run-help` argument displays the image's associated help message.
```
apptainer run-help $HOME/apptainer-images/lammps.sif
```

* The `inspect` argument displays the image's meta-data (owner, image's author, version, creation date, ...).
```
apptainer inspect $HOME/apptainer-images/lammps.sif
```

You may also directly execute the image, as a binary :
```
$ $HOME/apptainer-images/lammps.sif
```
which is strictly equivalent to `apptainer run $HOME/apptainer-images/lammps.sif`.

### Utiliser le conteneur LAMMPS
L'image `$HOME/apptainer-images/lammps.sif` embarque une version de LAMMPS supportant la parallélisation via **OpenMP** et **MPI**.

Dans le cas où aucune conteneurisation ne serait utilisée, la commande typique ressemblerait à :
```
OMP_NUM_THREADS=2 mpirun -np 4 lmp_mpi -in in.file
```

En utilisant ce conteneur, la même commande devient :
```
apptainer exec --env OMP_NUM_THREADS=2 $HOME/apptainer-images/lammps.sif mpirun -np 4 lmp_mpi -in in.file
```


### Isolation partielle ou isolation totale
Par défaut, Apptainer n'isole pas totalement le conteneur du système de la machine hôte. Les chemins suivants de la machine hôte sont montés et accessibles par défaut dans le conteneur : `$HOME`, `$PWD` `/sys`, `/proc`, `/tmp`, `/var/tmp`, `/etc/resolve.conf` et `/etc/passwd`.

Si l'on veut isoler le conteneur de la machine hôte, Apptainer propose différentes options (à adjoindre à `apptainer run`, `apptainer exec` ou `apptainer shell`) :

* l'utilisation du flag `--no-mount` pour délier un ou plusieurs chemins au sein du conteneur, par exemple :
```
apptainer run --no-mount $PWD,sys $HOME/apptainer-images/lammps.sif -in in.file
```

* l'utilisation du flag `--no-home` rend le répertoire `$HOME` inaccessible au conteneur (mais `$PWD` reste monté) :
```
apptainer run --no-home $HOME/apptainer-images/lammps.sif -in in.file
```

* le flag `--containall` isole totalement le conteneur de la machine hôte.
```
apptainer run --containall $HOME/apptainer-images/lammps.sif -in in.file
```

Dans le cas où l'option `--containall` est activée, le répertoire contenant les fichiers d'entrée de LAMMPS n'est pas accessible dans le conteneur ! Il faut alors le monter manuellement avec le flag `--bind` au répertoire où l'on se trouve par défaut dans le conteneur (`$HOME`). Par exemple :
```
apptainer run --containall --bind $PWD:$HOME $HOME/apptainer-images/lammps.sif -in in.file
```
dans le cas où les fichiers d'entrée de LAMMPS se situent dans le répertoire courant (`$PWD`).