# Comment utiliser l'image Apptainer d'Ovito

En préalable de ces explications, il est nécessaire d'avoir installé Apptainer sur votre machine ; voir [ce lien](https://www.apptainer-images.diamond.fr/install-apptainer/FR) pour plus de détails.

Ce tutoriel détaille l'utilisation de l'image de conteneur du code Ovito téléchargeable à [cette adresse](https://www.apptainer-images.diamond.fr/ovito). En suivant ce lien, vous récupérez une image Apptainer (format de fichier `.sif`) qui vous permattra de créer des conteneurs à même de faire tourner LAMMPS.

Pour plus d'informations sur les conteneurs Apptainer, veuillez consulter la [page dédiée](https://www.apptainer-images.diamond.fr/apptainer-containers/FR).

Pour rapidement s'approprier les principales commandes d'Apptainer, vous pouvez vous référer à [ce tutoriel](https://www.apptainer-images.diamond.fr/apptainer-tutorial/FR).

Cette image est un fichier relocalisable et renommable, qu'il est recommandé de placer dans un répertoire dédié pour facilement la retrouver ; celui-ci peut-être quelconque, et dans le cadre de ce tutoriel nous assumerons que vous l'avez placée dans un répertoire nommé `$HOME/apptainer-images` :
```
mkdir -p $HOME/apptainer-images
mv lammps.sif $HOME/apptainer-images/ovito.sif
```

Pour illustrer le fonctionnement du programme de visualisation, un jeu de fichiers de positions atomiques lisibles avec Ovito sont disponibles sous forme d'archive via [ce lien](https://www.tutoriels.diamond.fr/ovito-inputs). Cette archive contient les fichiers suivants :
* `C-diamond.cif` qui contient des positions d'atomes de Carbone formant une structure diamant au format *Crystallographic Information File*, l'un des formats de fichiers textes standards pour stocker les informations relatives à la structure de cristaux.
* `POSCAR_Si-diamond` qui est un fichier de positions d'une autre structure diamant, cette fois-ci pour des atomes de Silicium. Le format de ce fichier est celui utilisé par le code de simulation `VASP`, très populaire pour pour étudier la structure électronique des matériaux à l'échelle quantique.
* tout un jeu de fichiers `SiC.*.lmp` contenus dans un sous-dossier `MD`. Ces fichiers, au format utlisé par le code de simulation atomistique classique `LAMMPS`, retracent l'évolution d'un système hybride Silicium/Carbone au cours d'un calcul de dynamique moléculaire.

Dans ce tutoriel, on supposera que les fichiers d'entrée contenus dans cette archive sont dans le répertoire courant :
```
tar -xzf DIAMOND-tutorial.tar.gz # Extrait le contenu de l'archive, créée ./tutorial
cd ./tutorial
```

## TL; DR Commande en une ligne
Pour les personnes pressées, voici comment lancer l'outil de visualisation Ovito en utilisant l'image de conteneur (téléchargée au préalable et située à `$HOME/apptainer-images/ovito.sif`). Dans le cas où le répertoire courant contient un fichier d'entrée lisible par Ovito :
```
apptainer run --env DISPLAY=$DISPLAY $HOME/apptainer-images/ovito.sif <input.file>
```

## Détail d'utilisation du conteneur Ovito
Cette section présente les différentes manières d'utiliser l'image Ovito. Pour plus de détails sur les commandes Apptainer, veuillez vous référer à [ce tutoriel](https://www.apptainer-images.diamond.fr/apptainer-tutorial%basic-commands/FR).

Pour exécuter Ovito sans aucune conteneurisation, on utiliserait la commande :
```
ovito <input.file.1> <input.file.2> ...
```
où les fichiers d'entrée `input.file.X` sont optionnels et permettent de charger la ou les configurations que l'on veut afficher directement au lancement de l'application.

Avec Apptainer, le fonctionnement est similaire, à quelques détails près :
* il faut appeler Apptainer pour lancer le conteneur (une ligne de commande).
* il faut s'assurer que le conteneur a bien accès aux ressources graphiques de votre machine (une option dans la ligne de commande précedente).
* si on souhaite isoler le conteneur de notre machine (une autre option), alors il faut s'assurer de pouvoir accéder aux fichiers que l'on souhaite charger dans Ovito.

Chacun de ces points est détaillé dans l'une des sections suivantes.

### Lancer le conteneur Ovito avec Apptainer
Pour lancer une commande au sein d'un conteneur Apptainer, on peut utiliser `apptainer exec <nom de l'image> <commande>`, à laquelle on peut adjoindre des options que l'on détaillera dans les parties suivantes. Dans notre cas, où l'image est située au chemin `$HOME/apptainer-images/ovito.sif`, et où la commande est de la forme `ovito C-diamond.cif` avec le fichier de configuration atomique `C-diamond.cif` dans le répertoire courant, on peut donc faire :
```
apptainer exec $HOME/apptainer-images/ovito.sif ovito C-diamond.cif
```
> [!NOTE]
> Il est possible que cette commande ne fonctionne pas sur votre machine personnelle ; c'est très probablement parce que le conteneur ne peut pas accéder aux ressources graphiques de votre machine. pour résoudre ce problème, veuillez vous référer à la [section suivante](#partage-des-ressources-graphiques).

L'exécution de cette commande fonctionne de la manière suivante :
* création d'un conteneur à partir de l'image Apptainer `$HOME/apptainer-images/ovito.sif`.
* exécution, au sein de ce conteneur, de la commande `ovito C-diamond.cif`. Une fenêtre Ovito apparaît alors, avec laquelle on peut interagir comme on le ferait normalement si Ovito était installé sur notre machine..
* une fois que l'utilisation de l'application est terminée (c'est-à-dire quand on ferme la fenêtre Ovito), destruction du conteneur et libération des ressources.

On peut répliquer ce même comportement avec `apptainer run` qui appelle directement la commande par défaut de l'image, `ovito`, à laquelle on peut adjoindre des arguments.
```
apptainer run $HOME/apptainer-images/ovito.sif C-diamond.cif # la commande "ovito" est implicitement appellée.
```

On peut enfin appeler directement l'image comme un exécutable, ce qui est strictement identique à l'utilisation de `apptainer run` (pour la forme, changeons de fichier de configuration).
```
$HOME/apptainer-images/ovito.sif POSCAR_Si-diamond
```

### Partage des ressources graphiques
TEXT

### Isolation et accès aux fichiers
TEXT

### Afficher l'aide

## Exercices

### Exercice 1

### Exercice 2

### Exercice 3
