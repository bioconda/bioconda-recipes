#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
This package installs the GET_PANGENES code. It is recommended to run it in a
computer cluster with LSF or slurm, particularly for large genomes. 
To configure it for HPC (get_pangenes.pl -m) please check the documentation and
edit your own HPC.conf file , which should be placed in the same location as the
main script get_pangenes.pl, which you can find out with the following command:

$ which get_pangenes.pl

The documentation can be found at:

https://github.com/Ensembl/plant-scripts/tree/master/pangenes

EOF
