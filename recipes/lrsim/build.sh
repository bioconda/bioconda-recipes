#!/bin/bash

set -eux -o pipefail

rm -f DWGSIMSrc/samtools/bcftools/*.[oa]
bash make.sh

mkdir -p $PREFIX/share/lrsim
LRSIM_PROGS="simulateLinkedReads.pl dwgsim SURVIVOR msort extractReads samtools faFilter.pl"
LRSIM_FILES="${LRSIM_PROGS} 4M-with-alts-february-2016.txt"
chmod u+x "${LRSIM_PROGS}"
cp "${LRSIM_FILES}" $PREFIX/share/lrsim/
                                    
mkdir -p $PREFIX/bin
echo "#! /usr/bin/env bash" >> $PREFIX/bin/lrsim
echo "perl $PREFIX/share/lrsim/simulateLinkedReads.pl \"\$@\"" >> $PREFIX/bin/lrsim
chmod +x $PREFIX/bin/lrsim
