#!/bin/bash
set -e

MERQURY=$CONDA_PREFIX/share/merqury

merqury.sh 2>&1 | grep 'Usage: ' 1>/dev/null 2>&1
meryl 2>&1 | grep 'usage: meryl' 1>/dev/null 2>&1
meryl-lookup 2>&1 | grep 'usage: meryl-lookup' 1>/dev/null 2>&1
for script in $MERQURY/**/*.R; do $script --help 1>/dev/null 2>&1; done
for jar in $MERQURY/**/*.jar; do java -jar -Xmx128m $jar 1>/dev/null 2>&1; done
bedtools --version 1>/dev/null 2>&1
samtools --version 1>/dev/null 2>&1

