#!/bin/sh

set -x -e

# run gcluster
Gcluster -dir test_data/gbk -gene test_data/interested_gene_name.txt -tree test_data/16S_rRNA_tree.nwk -m 3 -PNG F

rm -rf test_data
