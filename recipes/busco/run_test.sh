#!/bin/bash

set -euo pipefail

cat > ex.fasta <<EOF
>1
AATTCC
EOF
wget http://busco.ezlab.org/datasets/proteobacteria_odb9.tar.gz
tar -xf proteobacteria_odb9.tar.gz

run_busco -i ex.fasta -o out -l proteobacteria_odb9 -m geno
