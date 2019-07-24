#!/usr/bin/env bash

## setting up directories
mkdir -p ${PREFIX}/share/gtotree/ncbi_tax_info/
mkdir -p ${PREFIX}/share/gtotree/hmm_sets/
mkdir -p ${PREFIX}/share/gtotree/example_data/

# setting up ncbi-tax
curl --silent --retry 10 -o ${PREFIX}/share/gtotree/ncbi_tax_info/taxdump.tar.gz ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
tar -xzf ${PREFIX}/share/gtotree/ncbi_tax_info/taxdump.tar.gz -C ${PREFIX}/share/gtotree/ncbi_tax_info/
rm ${PREFIX}/share/gtotree/ncbi_tax_info/taxdump.tar.gz

# setting up hmm-sets
cp -r hmm_sets/* ${PREFIX}/share/gtotree/hmm_sets/

## add database paths to activation script
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo 'export GToTree_HMM_dir=${CONDA_PREFIX}/share/gtotree/hmm_sets/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export TAXONKIT_DB=${CONDA_PREFIX}/share/gtotree/ncbi_tax_info/' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh

## adding variable for location of test data specifically, and example data
echo 'export TEST_DATA_DIR=${CONDA_PREFIX}/share/gtotree/example_data/test_data' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export EXAMPLE_DATA_DIR=${CONDA_PREFIX}/share/gtotree/example_data' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh

## adding variables to the conda environment so localization matches what the program expects
echo 'export LC_ALL="en_US.UTF-8"' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh
echo 'export LANG="en_US.UTF-8"' >> ${PREFIX}/etc/conda/activate.d/gtotree.sh

## making test files match the user info
sed -i.tmp "s|^|${PREFIX}/share/gtotree/example_data/test_data/|" test_data/genbank_files.txt
sed -i.tmp "s|^|${PREFIX}/share/gtotree/example_data/test_data/|" test_data/fasta_files.txt
sed -i.tmp "s|^|${PREFIX}/share/gtotree/example_data/test_data/|" test_data/amino_acid_files.txt
rm test_data/*.tmp

cp -r bin/ ${PREFIX}/bin/
cp -r test_data/ ${PREFIX}/share/gtotree/example_data/test_data/
cp -r ToL_example/ ${PREFIX}/share/gtotree/example_data/ToL_example/
cp -r example_run/ ${PREFIX}/share/gtotree/example_data/example_run/
cp LICENSE ${PREFIX}
