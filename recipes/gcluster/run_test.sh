#!/bin/sh


set -x -e

# run gcluster
Gcluster -dir ${RECIPE_DIR}/test_data/gbk -gene ${RECIPE_DIR}/test_data/interested_gene_name.txt -tree ${RECIPE_DIR}/test_data/16S_rRNA_tree.nwk -m 3 -PNG F

rm -rf ${RECIPE_DIR}/test_data
