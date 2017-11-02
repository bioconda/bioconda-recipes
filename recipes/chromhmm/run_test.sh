#!/bin/bash

# Tests the extra data download script
TMP=$(mktemp -d)
download_chromhmm_data.sh $TMP

# Check a handful of files across the directories that should have been created
for tst in \
    COORDS/mm10/RefSeqExon.mm10.bed.gz \
    ANCHORFILES/hg19/RefSeqTSS.hg19.txt.gz \
    CHROMSIZES/danRer7.txt \
    SAMPLEDATA_HG18/K562_chr11_binary.txt.gz \
; do
    fn=$TMP/$tst
    if [[ ! -e $fn ]]; then
        echo $fn does not exist
        exit 1
    fi
done
