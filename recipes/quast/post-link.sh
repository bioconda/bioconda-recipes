#!/bin/bash

cat >> "$PREFIX/.messages.txt" <<EOF
The default QUAST package does not include:
* Manta (needed for structural variants detection)
* SILVA 16S rRNA database (needed for reference genome detection in metagenomic datasets)

To be able to use those, please run
    quast-download-manta
    quast-download-blastdb
EOF
exit 0
