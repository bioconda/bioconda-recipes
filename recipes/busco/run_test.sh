#!/bin/bash

set -euo pipefail

cat > ex.fasta <<EOF
>1
AATTCC
EOF

export BUSCO_CONFIG_FILE="$PREFIX/config/config.ini"

run_BUSCO.py -i ex.fasta -o out -l proteobacteria_odb10 -m geno
