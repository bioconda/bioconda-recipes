#!/bin/bash

echo 'The default QUAST package does not include:'
echo '* Manta (needed for structural variants detection)'
echo '* SILVA 16S rRNA database (needed for reference genome detection in metagenomic datasets)'
echo ''
echo 'To be able to use those, please run'
echo '    quast-download-manta'
echo '    quast-download-blastdb'
exit 0
