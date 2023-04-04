#!/bin/bash

wget https://raw.githubusercontent.com/CSOgroup/CALDER2/main/tests/testthat/data/test.cool
wget https://raw.githubusercontent.com/CSOgroup/CALDER2/main/tests/testthat/data/test_gene_coverage.bed

calder --input test.cool --type cool --bin_size 50000 --genome hg38 --outpath out
calder --input test.cool --type cool --bin_size 50000 --genome hg38 --outpath out_feat --feature_track test_gene_coverage.bed