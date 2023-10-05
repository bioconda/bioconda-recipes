#!/bin/bash

wget https://raw.githubusercontent.com/artic-network/primer-schemes/master/nCoV-2019/V5.3.2/SARS-CoV-2.primer.bed
wget https://www.ebi.ac.uk/ena/browser/api/fasta/MN908947.3
sed 's/>ENA|MN908947|MN908947.3 Severe acute respiratory syndrome coronavirus 2 isolate Wuhan-Hu-1, complete genome./>MN908947.3/g' MN908947.3 > MN908947.3.fasta

amplisim \
    -o amplicons.fasta \
    MN908947.3.fasta \
    SARS-CoV-2.primer.bed
