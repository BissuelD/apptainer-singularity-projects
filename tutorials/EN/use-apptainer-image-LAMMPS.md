# How to use LAMMPS Apptainer image ?

In preamble, you need to have Apptainer installed on your machine ; see [this link](https://www.apptainer-images.diamond.fr/install-apptainer/EN) for more details.

This tutorial focuses on using the LAMMPS container image available at [this address](https://www.apptainer-images.diamond.fr/lammps). By following this link, you will get an Apptainer image (`.sif` file format) allowing you to create containers running LAMMPS.

For more information on Apptainer containers, please look at [this page](https://www.apptainer-images.diamond.fr/apptainer-containers/EN).

This image is a relocatable and renamable file we recommend putting in a dedicated directory to easily find it. While it can be any directory, in this tutoral we will assume you put it in `$HOME/apptainer-images` :
```
mkdir -p $HOME/apptainer-images
mv ./lammps-mpi-voro++-from-guix.sif $HOME/apptainer-images/lammps.sif
```

## TL; DR One liner command
For impatient folks, here is how to launch a parallel LAMMPS computation using the container image (previously dpwnloaded and stores in `$HOME/apptainer-images/lammps.sif`). In the case where the current directory contains all  mandatory LAMMPS input files :
```
apptainer exec $HOME/apptainer-images/lammps.sif mpirun -np <N> lmp_mpi -in <input.lammps>
```

## How to interact with the Apptainer image

### Apptainer : crash course
This section is aimed for people who have not used Apptainer yet.

The main way to interact with the image is through invoking the `apptainer` command, followed by different arguments :

* The `run` argument spawns a container from the image, runs the *container's default commannd* (here calling the `lmp_mpi` executable) within the container, and then destroys it.
```
$ apptainer run $HOME/apptainer-images/lammps.sif # exécute le binaire lmp_mpi dans le conteneur
```
You may also provide supplementary arguments to the default command by appending them at the end (eg. : `apptainer run $HOME/apptainer-images/lammps.sif -h`).

* The `exec` argument is similar to the `run` argument, only invoking **any** specified command inside the container. For example :
```
$ apptainer exec $HOME/apptainer-images/lammps.sif pwd
```
creates a container from the `$HOME/apptainer-images/lammps.sif` image, invokes the `pwd` command within the container, and then destroy it.

* The `shell` argument allows to enter an interactive shell inside the container (the `Apptainer>` *prompt* then appears on the left of the command line), run successive commands, then exit the container using `exit` or `Crtl+D`, which also destroys it. For example :
```
$ apptainer shell $HOME/apptainer-images/lammps.sif
Apptainer> pwd
Apptainer> cd ..
Apptainer> pwd
Apptainer> lmp_mpi -h # displays LAMMPS help message
Apptainer> exit
```

>[!Remark]
>
> Playing `exec` et `shell` you'll notice only a quite limited amount of commands are available from the container. In fact, commands intend to be as restricted as possible to the ones needed to run LAMMPS, both for portability (image size) and security reasons.

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


### Using the LAMMPS container
The `$HOME/apptainer-images/lammps.sif` image embedds a parallelized (through **OpenMP** and **MPI**) verison of LAMMPS.

In the case where no containerization would be used, the typical LAMMPS call would look like :
```
OMP_NUM_THREADS=2 mpirun -np 4 lmp_mpi -in in.file
```

Using the container, the same command becomes
```
apptainer exec --env OMP_NUM_THREADS=2 $HOME/apptainer-images/lammps.sif mpirun -np 4 lmp_mpi -in in.file
```

>[!Remark]
>
> Without any specification, LAMMPS uses by default a single **OpenMP** thread `$OMP_NUM_THREADS=1` and splitts **MPI** processes over all available cores.


### Partial or total isolation
By default, Apptainer does not fully isolate the container from the host system. The following paths of the host are mounted and dy default available from the container : `$HOME`, `$PWD` `/sys`, `/proc`, `/tmp`, `/var/tmp`, `/etc/resolve.conf` and `/etc/passwd`.

If one wishes to isolate the container from the host machine, Apptainer offers several options (to be added to `apptainer run`, `apptainer exec` or `apptainer shell`) :

* use the `--no-mount` flag to unbind one or several paths in the container, for instance
```
apptainer run --no-mount tmp,sys $HOME/apptainer-images/lammps.sif
```

* use the `--no-home` flad makes `$HOME` unavailable for the container (although `$PWD` ramains mounted) :
```
apptainer run --no-home $HOME/apptainer-images/lammps.sif
```

* use the `--containall` flag completely isolates the container from the host.
```
apptainer run --containall $HOME/apptainer-images/lammps.sif
```

When `--containall` is active, the directory containing LAMMPS input files cannot be accessed from the container ! It needs to be manually mounted with the `--bind` flag to the default directory we're located in the container (`$HOME`). For instance :
```
apptainer run --containall --bind $PWD:$HOME $HOME/apptainer-images/lammps.sif
```
in the case where LAMMPS input files are in the current directory (`$PWD`).

## Exercices

>[!First exercice]
>
> How to use the container image to run a sequential LAMMPS computation ?
> **Data**
> * The image is located at : `$HOME/apptainer-images/lammps.sif`
> * Input files (including the main input file `in.exercice`) are located in the current directory : `$PWD`
>
> Possible answers :
> `apptainer run $HOME/apptainer-images/lammps.sif -in in.exercice`
> or `apptainer exec $HOME/apptainer-images/lammps.sif lmp_mpi -in in.exercice`
> or `$HOME/apptainer-images/lammps.sif -in in.exercice`
> or
> ```
> apptainer exec \
>   --env OMP_NUM_THREADS=1 \
>   $HOME/apptainer-images/lammps.sif \
>   mpirun -np 1 lmp_mpi -in in.exercice
> ```


>[!Second exercice]
>
> How to use the container image to run a LAMMPS computation (1 **OpenMP** thread and 16 **MPI** cores) ?
> **Data**
> * The image is located at : `$HOME/apptainer-images/lammps.sif`
> * Input files (including the main input file `in.exercice`) are located in the current directory : `$PWD`
>
> Example of possible answer :
> ```
> apptainer exec \
>   $HOME/apptainer-images/lammps.sif \
>   mpirun -np 16 lmp_mpi -in in.exercice
> ```
> where `--env OMP_NUM_THREADS=1` is implicit and use by default by the container. 

>[!Third exercice]
>
> How to use the container image to run a LAMMPS computation (2 **OpenMP** threads and 8 **MPI** cores) which is fully isolated from the host system ?
> **Data**
> * The image is located at : `$HOME/apptainer-images/lammps.sif`
> * Input files (including the main input file `in.exercice`) are located at : `$HOME/lammps-examples/exercice/`
>
> Example of possible answer :
> ```
> apptainer exec \
>   --containall \
>   --env OMP_NUM_THREADS=2 \
>   --bind $HOME/lammps-examples/exercice/=$HOME \
>   $HOME/apptainer-images/lammps.sif \
>   mpirun -np 8 lmp_mpi -in in.exercice
> ```