#!/bin/bash

wget https://raw.githubusercontent.com/CSOgroup/CALDER2/main/tests/testthat/data/test.cool

calder --input test.cool --type cool --bin_size 50000 --genome hg38 --outpath out
