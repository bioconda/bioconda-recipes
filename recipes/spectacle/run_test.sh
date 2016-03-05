#!/bin/bash

# Basic tests for conda-specific wrapper and for the Spectacle-included python
# wrapper.
#
# Note that the ChromHMM recipe tests BinarizeBam, but that version of ChromHMM
# is not in Spectacle, so we test BinarizeBed instead.
Spectacle.sh -Xmx512M BinarizeBed | grep -q 'usage BinarizeBed'
Spectacle_python.py | grep -q 'file_directory fileID num_states'

# Tests the extra data download script
TMP=$(mktemp -d)
download_spectacle_data.sh $TMP

# Check a handful of files across the directories that should have been created
for tst in \
    COORDS/mm10/RefSeqExon.mm10.bed \
    ANCHORFILES/hg19/RefSeqTSS.hg19.txt \
    CHROMSIZES/danRer7.txt \
    SAMPLEDATA_HG18/K562_chr11_binary.txt \
    SAMPLEDATA_HG19/GM12878_chr10_binary.txt \
; do
    fn=$TMP/$tst
    if [[ ! -e $fn ]]; then
        echo $fn does not exist
        exit 1
    fi
done
