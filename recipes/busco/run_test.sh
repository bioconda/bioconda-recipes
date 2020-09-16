#!/bin/bash

set -euxo pipefail

prodigal
makeblastdb -h
tblastn -h
augustus
which gff2gbSmallDNA.pl
etraining
new_species.pl
optimize_augustus.pl
hmmsearch -h
run_sepp.py -h
