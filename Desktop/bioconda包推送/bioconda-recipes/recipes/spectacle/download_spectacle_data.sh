#!/bin/bash
set -e
set -o pipefail
set -x

if [[ -z "$1" ]]; then
    echo
    echo "Downloads Spectacle example data to <outdir>"
    echo "Usage: $0 <outdir>"
    echo
    exit 1
fi

OUTDIR=$(readlink -f $1)
mkdir -p $OUTDIR
TMP=$(mktemp -d)
cd $TMP
curl -O -L https://github.com/jiminsong/Spectacle/archive/v1.4.tar.gz > v1.4.tar.gz
tar -xf v1.4.tar.gz
cd Spectacle-1.4
unzip Spectacle.zip
mv $TMP/Spectacle-1.4/Spectacle/ANCHORFILES $OUTDIR
mv $TMP/Spectacle-1.4/Spectacle/CHROMSIZES $OUTDIR
mv $TMP/Spectacle-1.4/Spectacle/COORDS $OUTDIR
mv $TMP/Spectacle-1.4/Spectacle/SAMPLEDATA_HG19 $OUTDIR
mv $TMP/Spectacle-1.4/Spectacle/SAMPLEDATA_HG18 $OUTDIR
