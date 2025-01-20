#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
This package installs GET_PANGENES. As Whole Genome Alignments (WGA) can take a
long time to compute with large chromosomes (as in wheat), it is recommended to
run it in a high-performance computer (HPC) cluster with LSF or slurm. 
To configure it for HPC (get_pangenes.pl -m) please check the documentation and
edit your own 'HPC.conf' file , which should be placed in the same location as 
the main script get_pangenes.pl . This can be done in 3 steps:

1) Find out the location of GET_PANGENES in your filesystem: 

    $ which get_pangenes.pl

2) Create and edit a text file named 'HPC.conf'. 
2.1) Example for HPC managed by slurm:

    # cluster/farm configuration file, edit as needed (use spaces or tabs)
    # PATH might be empty or set to a path/ ending with '/'
    TYPE    slurm
    SUBEXE  sbatch
    CHKEXE  squeue
    DELEXE  scancel
    ERROR   F
    # 70GB was enough for chr-split wheat analysis with minimap2
    QARGS   -p production --time=24:00:00 --mem 70G

2.2) Example for HPC managed by LSF:

    # PATH might be empty or set to a path/ ending with '/'
    PATH    /path/to/lsf/bin/
    TYPE    lsf
    SUBEXE  bsub
    CHKEXE  bjobs
    DELEXE  bkill
    ERROR   EXIT
    QARGS   -q production -M 20G 

3) Copy the HPC config file to the location of GET_PANGENES, see step 1):

    $ cp HPC.conf /path/to/get_pangenes.pl

The complete documentation can be found at:

https://github.com/Ensembl/plant-scripts/tree/master/pangenes

EOF
