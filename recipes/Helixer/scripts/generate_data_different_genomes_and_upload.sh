#! /bin/bash

# Generates single genome datasets of one size and uploads them to the clc and the cluster

db_path='/home/felix/Desktop/full_geenuff.sqlite3'
local_main_folder_input="/home/felix/git/GeenuFF/tmp/"
local_main_folder_output="/home/felix/Desktop/data/single_genomes/"
clc_login="felix-stiehler@134.99.200.63"
cluster_login="festi100@hpc.rz.uni-duesseldorf.de"
remote_main_folder_clc="/home/felix-stiehler/Desktop/data/single_genomes/"
remote_main_folder_cluster="/scratch_gs/festi100/data/single_genomes/"
len_in_k=20

echo -e "\nCreating main folders if not existing"
mkdir -v -p "$local_main_folder_output"
ssh "$clc_login" mkdir -p "$remote_main_folder_clc"
ssh "$cluster_login" mkdir -p "$remote_main_folder_cluster"

for genome in $(ls -1 $local_main_folder_input)
do
	folder_out="$local_main_folder_output$genome/h5_data_$len_in_k""k"

	echo -e "\nGenerating $genome"
	../export.py --db-path-in $db_path --out-dir $folder_out --chunk-size "$len_in_k"000 --genomes $genome --one-hot --only-test-set

	echo -e "\nSending $genome"
	rsync -rvz --progress "$folder_out" "$clc_login:$remote_main_folder_clc$genome/"
	rsync -rvz --progress "$folder_out" "$cluster_login:$remote_main_folder_cluster$genome/"
done
