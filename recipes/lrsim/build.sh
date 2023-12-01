#!/bin/bash

set -eux -o pipefail

rm -f DWGSIMSrc/samtools/bcftools/*.[oa]
bash make.sh

mkdir -p $PREFIX/share/lrsim
for LRSIM_PROG in simulateLinkedReads.pl dwgsim SURVIVOR msort extractReads samtools faFilter.pl
do
    cp ${LRSIM_PROG} $PREFIX/share/lrsim/
    chmod u+x $PREFIX/share/lrsim/${LRSIM_PROG}
done
cp 4M-with-alts-february-2016.txt $PREFIX/share/lrsim/
                                    
mkdir -p $PREFIX/bin
echo "#! /usr/bin/env bash" >> $PREFIX/bin/lrsim
echo "set -eux -o pipefail" >> $PREFIX/bin/lrsim
echo "perl $PREFIX/share/lrsim/simulateLinkedReads.pl \"\$@\"" >> $PREFIX/bin/lrsim
chmod +x $PREFIX/bin/lrsim

cat $PREFIX/bin/lrsim
bash -x clean.sh
