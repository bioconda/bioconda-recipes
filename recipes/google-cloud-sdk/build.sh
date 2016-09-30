#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r * $outdir
for FNAME in gcloud gsutil bq
do
    sed -i.bak 's$# <cloud-sdk-sh-preamble>$export CLOUDSDK_PYTHON=/opt/anaconda1anaconda2anaconda3/bin/python$' $outdir/bin/$FNAME
    ln -s $outdir/bin/$FNAME $PREFIX/bin
done
