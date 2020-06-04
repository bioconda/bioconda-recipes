#!/bin/bash
set -euo pipefail

parsnp -V >/dev/null
parsnp -g examples/mers_virus/ref/England1.gbk -d example/mers_virus/genomes/*.fna -C 1000 -c -o test --verbose --use-fasttree
parsnp -r ! -d examples/mers_virus/genomes/*.fna -o test2 --verbose
