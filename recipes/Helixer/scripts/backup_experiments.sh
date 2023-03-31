#! /bin/bash
# from troodon:/mnt/data/experiments_backup
unalias rsync &> /dev/null

echo -e "\n----------------\n"
date
echo

echo -e "\nnni local felix"
rsync -rzt --ignore-existing --stats /home/felix/nni nni_local_felix/
rsync -rzt --stats /home/felix/.local/nnictl nni_local_felix/

echo -e "\nnni clc server"
rsync -rzt --ignore-existing --stats  felix-stiehler@134.99.200.63:/home/felix-stiehler/nni nni_clc_server/
rsync -rzt --stats  felix-stiehler@134.99.200.63:/home/felix-stiehler/.local/nnictl nni_clc_server/

echo -e "\nnni cluster"
rsync -rzt --ignore-existing --stats festi100@hpc.rz.uni-duesseldorf.de:/home/festi100/nni nni_cluster/
rsync -rzt --stats festi100@hpc.rz.uni-duesseldorf.de:/home/festi100/.local/nnictl nni_cluster/

echo -e "\ncluster jobs"
rsync -rzt --ignore-existing --stats festi100@hpc.rz.uni-duesseldorf.de:/home/festi100/git/HelixerPrep/jobs cluster_jobs/
