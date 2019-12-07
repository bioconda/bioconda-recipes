#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
make

cp RepeatScout build_lmer_table compare-out-to-gff.prl filter-stage-1.prl filter-stage-2.prl merge-lmer-tables.prl ${PREFIX}/bin
