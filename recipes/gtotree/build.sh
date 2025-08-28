#!/usr/bin/env bash

## setting up directories
mkdir -p ${PREFIX}/share/gtotree/ncbi_assembly_summaries/
mkdir -p ${PREFIX}/share/gtotree/hmm_sets/
mkdir -p ${PREFIX}/share/gtotree/ncbi_tax_info/
mkdir -p ${PREFIX}/share/gtotree/gtdb_tax_info/
mkdir -p ${PREFIX}/share/gtotree/kofamscan_data/

# ncbi assembly summaries added when used, placeholder so location not deleted on creation
touch ${PREFIX}/share/gtotree/ncbi_assembly_summaries/date-retrieved.txt

# hmms are added when used, we copy a file into that location below, so it won't be deleted upon creation

# ncbi-tax added when used, placeholder so location not deleted on creation
touch ${PREFIX}/share/gtotree/ncbi_tax_info/nodes.dmp

# gtdb info added when used, placehoder so location not deleted on creation
touch ${PREFIX}/share/gtotree/gtdb_tax_info/GTDB-arc-and-bac-metadata.tsv

# kofamscan data is added when used, placeholder so the dir is not deleted on creation
touch ${PREFIX}/share/gtotree/kofamscan_data/README

## add database paths in variables to activation script
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo 'export NCBI_assembly_data_dir=${CONDA_PREFIX}/share/gtotree/ncbi_assembly_summaries/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export GToTree_HMM_dir=${CONDA_PREFIX}/share/gtotree/hmm_sets/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export TAXONKIT_DB=${CONDA_PREFIX}/share/gtotree/ncbi_tax_info/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export GTDB_dir=${CONDA_PREFIX}/share/gtotree/gtdb_tax_info/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export KO_data_dir=${CONDA_PREFIX}/share/gtotree/kofamscan_data/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh

## adding variables to the conda environment so localization matches what the program expects
echo 'export LC_ALL="en_US.UTF-8"' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export LANG="en_US.UTF-8"' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh

cp -r bin/* ${PREFIX}/bin/
cp hmm_sets/* ${PREFIX}/share/gtotree/hmm_sets/
cp LICENSE ${PREFIX}

## this is intended to help with users who don't have write access in the conda environment location
## it's managed by the gtt-data-locations program
echo '
if [ -f ~/.config/gtotree/gtotree.sh ] && [ ! -w ${CONDA_PREFIX}/etc/conda/activate.d/gtotree.sh ]; then
    . ~/.config/gtotree/gtotree.sh
fi
' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
