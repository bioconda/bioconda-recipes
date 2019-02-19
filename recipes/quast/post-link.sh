#!/bin/bash

cat >> "$PREFIX/.messages.txt" <<EOF
The default QUAST package does not include:
* GRIDSS (needed for structural variants detection)
* SILVA 16S rRNA database (needed for reference genome detection in metagenomic datasets)
* BUSCO tools and databases (needed for searching BUSCO genes) -- works in Linux only!

To be able to use those, please run
    quast-download-gridss
    quast-download-silva
    quast-download-busco
EOF
exit 0
