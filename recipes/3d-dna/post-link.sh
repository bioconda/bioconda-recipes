#!/usr/bin/env bash

cat > "${PREFIX}"/.messages.txt <<- EOF

    3d-dna files installed to $PREFIX/share/3d-dna

    executable '3d-dna' added to PATH, an alias for $PREFIX/share/3d-dna/run-asm-pipeline.sh
    e.g. you can run '3d-dna contigs.fa hic.mnd'

EOF
