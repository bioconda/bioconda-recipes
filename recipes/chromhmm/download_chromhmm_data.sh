#!/bin/bash
set -e
set -o pipefail
set -x

if [[ -z "$1" ]]; then
    echo
    echo "Downloads ChromHMM example data to <outdir>"
    echo "Usage: $0 <outdir>"
    echo
    exit 1
fi
OUTDIR=$1
mkdir -p $OUTDIR
TMP=$(mktemp -d)
cd $TMP
curl -O -L http://compbio.mit.edu/ChromHMM/ChromHMM.zip > ChromHMM.zip
unzip ChromHMM

mv $TMP/ChromHMM/ANCHORFILES $OUTDIR
mv $TMP/ChromHMM/CHROMSIZES $OUTDIR
mv $TMP/ChromHMM/COORDS $OUTDIR
mv $TMP/ChromHMM/SAMPLEDATA_HG18 $OUTDIR
