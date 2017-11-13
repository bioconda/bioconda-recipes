#!/bin/bash

mkdir -p ${PREFIX}/bin
chmod +x *.sh
cp {*.sh,*.pl,*.r} ${PREFIX}/bin

# test using official example
mkdir testdata
curl bioinf.uni-freiburg.de/~maticzkd/jamm_testdata/ctcfRep1.chr21.bed > testdata/ctcfRep1.chr21.bed
curl bioinf.uni-freiburg.de/~maticzkd/jamm_testdata/ctcfRep2.chr21.bed > testdata/ctcfRep2.chr21.bed
curl bioinf.uni-freiburg.de/~maticzkd/jamm_testdata/chrSizes21.csize > chrSizes21.csize
time bash JAMM.sh -s testdata -g chrSizes21.csize -o jamm_out
ls jamm_out/peaks/all.peaks.narrowPeak # non-zero return if file not found
