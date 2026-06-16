#!/bin/bash

# copy scripts and its dependencies to $PREFIX/bin folder
mkdir -p ${PREFIX}/bin
mv  lib \
    utils \
    WGA \
    vcf2alignment \
    vcf2synteny \
    version.txt \
    ${PREFIX}/bin

# copy sample_data
mv sample_data Makefile ${PREFIX}

cd ${PREFIX}/bin

# WGA must use Bioconda's GSAlign and Red
perl -pi.bak -e 's/\$Bin\/lib\/GSAlign\/bin\///; s/my \$REDEXE.*/my \$REDEXE=`which Red`;chomp(\$REDEXE);/; s/\-\-cor/--exe \$REDEXE --cor/g' WGA

## get Red2Ensembl, adapt it to bioconda's Red 
cd utils && wget https://raw.githubusercontent.com/Ensembl/plant-scripts/refs/heads/master/repeats/Red2Ensembl.py && \
    chmod +x Red2Ensembl.py && perl -pi.bak -e 's/frm 3/frm 2/' Red2Ensembl.py && cd ..

# CGaln
cd lib && git clone https://github.com/rnakato/Cgaln.git && cd Cgaln && \
    perl -pi.bak -e 's/CC = gcc//;s/gcc/\$(CC)/' Makefile && make && rm -f *.fasta *.o && cd ../..
