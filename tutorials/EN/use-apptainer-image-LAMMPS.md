# How to use LAMMPS Apptainer image ?

In preamble, you need to have Apptainer installed on your machine ; see [this link](https://www.apptainer-images.diamond.fr/install-apptainer/EN) for more details.

This tutorial focuses on using the LAMMPS container image available at [this address](https://www.apptainer-images.diamond.fr/lammps). By following this link, you will get an Apptainer image (`.sif` file format) allowing you to create containers running LAMMPS.

For more information on Apptainer containers, please look at [this page](https://www.apptainer-images.diamond.fr/apptainer-containers/EN).

To have a quick look at Apptainer's main commands, you may refer to [this tutorial](https://www.apptainer-images.diamond.fr/apptainer-tutorial/EN).

This image is a relocatable and renamable file we recommend putting in a dedicated directory to easily find it. While it can be any directory, in this tutorial we will assume you put it in `$HOME/apptainer-images` :
```
mkdir -p $HOME/apptainer-images
mv lammps.sif $HOME/apptainer-images/lammps.sif
```

## TL; DR One liner command
For impatient folks, here is how to launch a parallel LAMMPS computation using the container image (previously downloaded and stored in `$HOME/apptainer-images/lammps.sif`). In the case where the current directory contains all  mandatory LAMMPS input files :
```
apptainer exec $HOME/apptainer-images/lammps.sif mpirun -np <N> lmp_mpi -in <input.lammps>
```

## Detailed usage for the LAMMPS container
This section presents different ways to use the LAMMPS image. For more details about Apptainer commands, please look at [this tutorial](https://www.apptainer-images.diamond.fr/apptainer-tutorial%basic-commands/EN).

### Using the LAMMPS container for sequential runs
To run LAMMPS sequentially (*ie.* without parallelization) without any container, one would use the following command :
```
lmp_mpi -in in.file
```
where all LAMMPS input files (including `in.file`, the main input) are stored in the current directory.

To do the same inside a container, we can run three equivalent commands. In each case, we suppose the Apptainer image  `lammps.sif` can be found at `$HOME/apptainer-images/lammps.sif`.

* One can use `apptainer exec` to execute a specific command in the container.
```
apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -in in.file
```

* One can use `apptainer run` to call the container's *default* command, namely the `lmp_mpi` executable. We also append instructions at the end of the command allowing to locate LAMMPS input file.
```
apptainer run $HOME/apptainer-images/lammps.sif -in in.file # "lmp_mpi" is implicitly called by "run"
```

* One can eventually execute the image as a binary, which is strictly identical to using `apptainer run`.
```
$HOME/apptainer-images/lammps.sif -in in.file
```

### Using the LAMMPS container for parallel runs
The `$HOME/apptainer-images/lammps.sif` image embedds a parallelized (through **OpenMP** and **MPI**) version of LAMMPS.

In the case where no containerization would be used, the typical LAMMPS call would look like :
```
OMP_NUM_THREADS=2 mpirun -np 4 lmp_mpi -in in.file
```

Using the container, the same command becomes
```
apptainer exec --env OMP_NUM_THREADS=2 $HOME/apptainer-images/lammps.sif mpirun -np 4 lmp_mpi -in in.file
```

**Remark**
> Without any specification, LAMMPS uses by default a single **OpenMP** thread (`$OMP_NUM_THREADS=1`) and splitts **MPI** processes over all available cores.

### Display help
To display the container's help message (supposing the image is stored at `$HOME/apptainer-images/lammps.sif`) :
```
apptainer run-help $HOME/apptainer-images/lammps.sif
```

To display the container's meta-data (code owner, version, image author, ...) :
```
apptainer inspect $HOME/apptainer-images/lammps.sif
```

To run the help command specific to the LAMMPS executable in the container (`lmp_mpi`) :
```
apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -h
```
or
```
apptainer run $HOME/apptainer-images/lammps.sif -h
```
or
```
$HOME/apptainer-images/lammps.sif -h
```

### Partial or total isolation
By default, Apptainer does not fully isolate the container from the host system. One can either have partial or total isolation using respectively the flags `--no-mount` or `--no-home` and `--contain-all` (see [this link](https://www.apptainer-images.diamond.fr/apptainer-tutorial%isolation/EN) for more information).

Whenever `--containall` is activated, the directory on the host machine containing LAMMPS input-files cannot be accessed from the container !
```
apptainer run --containall $HOME/apptainer-images/lammps.sif -in in.file # in.file not found !
```
It is then required to manually mount the current directory (`$PWD`) to the one where we are located by default in the container (`$HOME`) using the `--bind` flag. For instance :
```
apptainer run --containall --bind $PWD:$HOME \ # Mounting the current directory to $HOME in the container.
  $HOME/apptainer-images/lammps.sif -in in.file
```
in the case where LAMMPS input files are in the current directory (`$PWD`).

### Potentiels interatomiques
In LAMMPS, interactions between atoms are defined through force fields (or interatomic potentials). Their parameters are specified inside formatted files. The type of interaction to be applied (*ie.* the type of file to look for) is explicited in LAMMPS main input file (*eg.* named `in.file`). At runtime, the code looks for the corresponding files in the following order :

* First, it looks for a file corresponding (location, potential type, name, ...) to what's defined in the main input (`in.file`).
* If nothing is found that corresponds to the instructions of the main input (`in.file`), the code then looks in the directory defined by the `$LAMMPS_POTENTIALS` environment variable.

For this specific container image, the `$LAMMPS_POTENTIALS` variable points inside the container to `/usr/share/lammps/potentials`. This directory contains the default potenital files included with the version LAMMPS present in the container.

In the (quite rare) case where one has another set of potential they wish to use by default, it is however possible to alter this behaviour. This is achievable in two ways :

* On one hand, we can overwite the content of `/usr/share/lammps/potentials` by mounting another directory from the host machine to this very path (using `--bind`). In such cases, `$LAMMPS_POTENTIALS` still points towards `/usr/share/lammps/potentials` but the content of this directory is overwritten.
```
# We overwrite /usr/share/lammps/potentials in the container.
apptainer run --bind /new/path/with/potential/on/host/:/usr/share/lammps/potentials \
  $HOME/apptainer-images/lammps.sif -in in.file
```

* On the other hand, one can also redefine `$LAMMPS_POTENTIALS` (using `--env`) to make it point to another path from the host machine (just be sure to also have it available in the container). Here, `$LAMMPS_POTENTIALS` is modified and the code looks for potentials in the newly defined path.
```
# If no isolation option is used, $HOME/lammps-potentials
# is shared with the container.
apptainer run --env LAMMPS_POTENTIALS=$HOME/lammps-potentials \
  $HOME/apptainer-images/lammps.sif -in in.file


# By default, /opt/lammps-potentials is not shared between the host and the container
# We have to mount this directory with --bind.
apptainer run --env LAMMPS_POTENTIALS=/opt/lammps-potentials \ # redefining $LAMMPS_POTENTIALS
  --bind /opt/lammps-potentials:/opt/lammps-potentials       \ # mount the directory in the container
  $HOME/apptainer-images/lammps.sif -in in.file
```

## Exercices

### First exercice
How to use the container image to run a sequential LAMMPS computation ?

**Data**
> * The image is located at : `$HOME/apptainer-images/lammps.sif`
> * Input files (including the main input file `in.exercice`) are located in the current directory : `$PWD`

Possible answers :
* `apptainer run $HOME/apptainer-images/lammps.sif -in in.exercice`
* or `apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -in in.exercice`
* or `$HOME/apptainer-images/lammps.sif -in in.exercice`
* or
```
apptainer exec \
  --env OMP_NUM_THREADS=1 \
  $HOME/apptainer-images/lammps.sif \
  mpirun -np 1 lmp_mpi -in in.exercice
```


### Second exercice
How to use the container image to run a LAMMPS computation (1 **OpenMP** thread and 16 **MPI** cores) ?

**Data**
> * The image is located at : `$HOME/apptainer-images/lammps.sif`
> * Input files (including the main input file `in.exercice`) are located in the current directory : `$PWD`

Example of a possible answer :
```
apptainer exec \
  $HOME/apptainer-images/lammps.sif \
  mpirun -np 16 lmp_mpi -in in.exercice
```
where `--env OMP_NUM_THREADS=1` is implicit and use by default by the container. 

### Third exercice
 How to use the container image to run a LAMMPS computation (2 **OpenMP** threads and 8 **MPI** cores) which is fully isolated from the host system ?

**Data**
> * The image is located at : `$HOME/apptainer-images/lammps.sif`
> * Input files (including the main input file `in.exercice`) are located at : `$HOME/lammps-examples/exercice/`

Example of a possible answer :
```
apptainer exec \
  --containall \
  --env OMP_NUM_THREADS=2 \
  --bind $HOME/lammps-examples/exercice/=$HOME \
  $HOME/apptainer-images/lammps.sif \
  mpirun -np 8 lmp_mpi -in in.exercice
```