#!/bin/bash
set -eu -o pipefail

MERQURY=$CONDA_PREFIX/share/merqury

merqury.sh
meryl 2>&1 | grep 'usage: meryl'
meryl-lookup 2>&1 | grep 'usage: meryl-lookup'
for script in $MERQURY/**/*.R; do $script --help; done
for jar in $MERQURY/**/*.jar; do java -jar -Xmx128m $jar; done
igvtools version
bedtools --version
samtools --version

