# Utiliser Apptainer en parallèle

Si l'image Apptainer que vous voulez utiliser supporte le calcul parallèle, alors OpenMPI fait partie des librairies inclues au sein du conteneur. Dans ce cas, il est intéressant d'utiliser cette solution de parallélisation pour accélèrer votre calcul. Si on se réfère à la [documentation](https://apptainer.org/docs/user/latest/mpi.html) officielle d'Apptainer, il existe deux modes d'utilisation d'OpenMPI avec Apptainer : le mode hybride et le mode de liaison. Ces modes sont plébiscités lorsque lorsque le conteneur est utilisé sur des infrastructures de type HPC. Cependant, un troisième mode peut être employé si le conteneur est lancé sur une machine personnelle : le mode embarqué. Dans cette documentation, nous détaillerons :

- le mode [embarqué]({{< ref "#embedded_mode" >}}),
- le mode [hybride]({{< ref "#hybrid_mode" >}}).

**Disclaimer**
> Les commandes Apptainer ci-dessous ont été simplifiées au maximum dans un but de lisibilité. Il est possible de combiner l'utilisation des commandes `mpirun` avec le flag `--containall`, tout en montant des dossiers spécifiques au conteneur avec les flags `--bind` et en renseignant des variables d'environnement `--env`. Les possibilités sont multiples. Nous vous conseillons donc de jeter un oeil à la documentation relative à ces [sujets]({{< ref "/content/fr/documentation/use-apptainer-image/howto.md" >}}).

## Le mode embarqué {#embedded_mode}

Si vous voulez utilisez votre image Apptainer en parallèle sur votre machine locale, alors vous pouvez utiliser la librairie OpenMPI qui a été embarquée lors de la création de l'image de conteneur.  
Cette approche a l'énorme avantage de vous exempter de tous souci relatif à la version d'OpenMPI installée sur votre machine, et même de savoir si cette librairie est installée tout court.

Il est alors très simple, grâce à la commande `apptainer exec`, d'exécuter des commandes `mpirun` qui appellent les outils de parallélisation inclus dans votre image de conteneur :

```bash
apptainer exec \
  image_apptainer.sif \
  mpirun -np nb_procs commande ...
```

Toutefois, cette utilisation en mode embarqué d'OpenMPI est principalement utile lorsque l'on veut faire tourner des tests sur une machine locale, lorsque les performances numériques ne sont pas une priorité majeure. En effet, cette simplicité d'utilisation s'accompagne d'un contrecoup majeur, puisque l'on ne tire pas pleinement parti des ressources matérielles de la machine hôte : la version d'OpenMPI présente au sein du conteneur n'est pas optimisée pour votre machine précise, et dans la plupart des cas observés pour l'écriture de ce tutoriel on plafonne à une utilisation maximale du CPU de l'ordre de 85-90%.

## Le mode hybride {#hybrid_mode}

(@Benjamin tu disais ici que le mode embarqué pourrait ne pas marcher sur une machine HPC. As-tu déjà observé ça ? pour l'instant j'ai supprimé mais on pourra remettre.)
Nous venons de voir que l'utilisation d'OpenMPI en mode embarqué sur des infrastrucutres de type HPC, où l'efficacité numérique est centrale, ne serait pas souhaitable en raisons de performances numériques suboptimales. Comme expliqué dans la documentation d'Apptainer, il est préférable d'utiliser le mode hybride sur des infrastructures de type HPC. Dans ce cas, il y faut mettre en place un "dialogue" qui s'opère entre OpenMPI de la machine hôte (sur l'infrastucture de type HPC) et OpenMPI embarqué dans l'image Apptainer. Pour mieux comprendre la différence conceptuelle entre ce mode hybride et le mode embarqué discuté plus haut, on peut jeter un œil au schéma ci-dessous.
(NOTE : INCLURE SCHÉMA OPENMPI EMBARQUÉ/HYBRIDE ICI).

Pour de la parallélisation hybride, l'appel à la commande OpenMPI (`mpirun`) ne se fait plus au sein du conteneur - c'est-à-dire après `apptainer exec` comme pour le mode embarqué - mais à l'extérieur de celui-ci. On utilise donc une commade de la forme :
```bash
mpirun -np nb_procs <options-OpenMPI> \
        apptainer exec image_apptainer.sif \
        commande ...

```
Par cette approche, c'est la version d'OpenMPI installée sur la machine hôte qui sera appelée, et qui échangera avec la version de la librairie et le code installés au sein du conteneur instancié par `apptainer exec`. Selon les spécificités de la machine hôte, quelques options OpenMPI (`<option-OpenMPI>`) peuvent être nécessaires, et sont discutées plus bas. 


Dans les faits, afin d'optimiser réellement les performances, il faut passer par une complexité supplémentaire via l'utilisation des instances Apptainer. Cela permet en effet d'homogénéiser les namespaces des processus OpenMPI, favorisant ainsi la communication entre les processus. Pour cela, on procède de la manière suivante :

```bash
# on lance une instance apptainer sur chaque nœud de calcul
mpirun -npernode 1 \
        apptainer instance start \
        image_apptainer.sif nom_instance

# on lance le code/script avec la commande MPI
mpirun -np nb_procs \
        apptainer exec instance://nom_instance \
        /bin/bash -c "commande..."

# on stoppe les instances apptainer sur chaque nœud de calcul
mpirun -npernode 1 \
        apptainer instance stop nom_instance
```

Si vous voulez utiliser des flags spécifiques pour exécuter votre conteneur, il faut le faire à la création de l'instance. Par exemple, pour monter des dossiers spécifiques avec le paramètre `--bind`, cela donne : 
```bash
mpirun -npernode 1 \
        apptainer instance start \
        --bind chemin_dossier_machine_hote:chemin_dossier_conteneur \
        image_apptainer.sif nom_instance
```

## Conseils et bonnes pratiques

### Paramètres OpenMPI

En pratique, l'exécution de commandes OpenMPI peut nécessiter des arguments ou options supplémentaires comme le `--prefix`, le `plm_rsh_agent` ou `OMP_NUM_THREADS`. Étant donné que ces paramètres peuvent évoluer d'une infrastructure à l'autre, il est recommandé de se référer aux documentations des infrastuctures en question. En voici quelques unes en lien avec le PEPR DIADEM :

- [Gricad](https://gricad-doc.univ-grenoble-alpes.fr/hpc/softenv/container/)
- [TGCC](https://www-hpc.cea.fr/tgcc-public/en/html/toc/fulldoc/Virtualization.html?highlight=singularity)
- et bien d'autres ...

### Inter-compatibilité de versions

Bien qu'il existe une compatibilité OpenMPI inter-version, l'utilisation de versions différentes d'OpenMPI peut résulter en des [baisses de performances](https://github.com/ckhroulev/apptainer-with-ompi/tree/main). Il est donc plus simple, quand c'est possible d'utiliser la même version d'OpenMPI sur la machine hôte que dans le conteneur. Pour cela, on peut fonctionner de deux manières : en sélectionnant, quand c'est possible, la version la plus adaptée d'OpenMPI disponible sur le cluster HPC que vous utilisez, ou alors à l'inverse en installant directement la même version d'OpenMPI que celle du cluster dans l'image Apptainer lors de sa construction.
Dans le cadre du PEPR DIADEME, les images de conteneurs mises à disponibilité sont construites sans connaissance préalable exhaustive des machines sur lesquelles elles seront utilisées ; il est donc ardu de choisir *a priori* la version qu'il **vous** faut pour l'inclure dans le conteneur.

Si vous voulez connaître la version d'OpenMPI inclue dans une image donnée, ainsi que d'autres informations utiles, vous pouvez appeler `ompi_info` comme ceci :
```bash
apptainer exec \
  image_apptainer.sif \
  ompi_info
```
