# Utiliser Apptainer en parallèle

Si l'image Apptainer que vous voulez utiliser supporte le calcul parallèle, alors OpenMPI fait partie des librairies conteneurisées. Dans ce cas, il est intéressant d'utiliser cette parallélisation pour accélèrer votre calcul. Si on se réfère à la [documentation](https://apptainer.org/docs/user/latest/mpi.html) officielle d'Apptainer, il existe uniquement deux modes d'utilisation d'OpenMPI avec Apptainer : le mode hybride et le mode de liaison. Ces modes sont plébiscités lorsque lorsque le conteneur est utilisée sur des infrastructures de type HPC. Cependant, un troisième mode peut être utilisé si le conteneur est lancé sur une machine personnelle : le mode embarqué. Dans cette documentation, nous détaillerons :

- le mode [embarqué]({{< ref "#embedded_mode" >}}),
- le mode [hybride]({{< ref "#hybrid_mode" >}}).

**Disclaimer**
> Les commandes Apptainer ci-dessous ont été simplifiées au maximum dans un but de lisibilité. Il est possible de combiner l'utilisation des commandes `mpirun` avec le flag `--containall`, tout en montant des dossiers spécifiques au conteneur avec les flags `--bind` et en renseignant des variables d'environnement `--env`. Les possibilités sont multiples. Nous vous conseillons donc de jeter un oeil à la documentation relative à ces [sujets]({{< ref "/content/fr/documentation/use-apptainer-image/howto.md" >}}).

## Le mode embarqué {#embedded_mode}

Si vous voulez utilisez votre image apptainer en parallèle sur votre machine local, alors vous pouvez utiliser la librairie OpenMPI qui a été conteneurisé.  
vous n'êtes pas obliger d'installer OpenMPI. Vous n'êtes pas obligés d'installer OpenMPI sur votre machine. En effet, grâce à la commande `apptainer exec`, vous pouvez exécuter des commandes `mpirun` :

```bash
apptainer exec \
  image_apptainer.sif \
  mpirun -np nb_procs commande ...
```

## Le mode hybride {#hybrid_mode}

L'utilisation de la commande précèdente sur des infrastrucutres de type HPC ne serait pas efficace (avec des baisses de performances notables), voire provoquerait une erreur d'exécution. Comme expliqué dans la documentation d'Apptainer, il est préférable d'utiliser le mode hybride sur des infrastructures de type HPC. Dans ce cas, il y a un "dialogue" qui s'opère entre OpenMPI de la machine hôte (sur l'infrastucture de type HPC) et OpenMPI embarqué dans l'image Apptainer. Un autre point important est qu'il faut utiliser les instances Apptainer pour des performances optimales. Cela permet en effet d'homogénéiser les namespaces des processus OpenMPI, favorisant ainsi la communication entre les processus. Dans ce cas, on procède de la manière suivante :

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

Bien qu'il y existe une compatibilité OpenMPI inter-version, l'utilisation de versions différentes d'OpenMPI résulte en des [baisses de performances](https://github.com/ckhroulev/apptainer-with-ompi/tree/main). Il est donc recommandé d'utiliser la même version d'OpenMPI sur la machine hôte que dans le conteneur. En pratique, il faut donc veiller à installer la même version d'OpenMPI avec le gestionnaire de paquets de l'infrastructure de calcul.