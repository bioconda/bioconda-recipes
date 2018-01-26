#!/bin/bash
set -eu -o pipefail

MODEL_VERSION="0.4.0"
MODEL_NAME="DeepVariant-inception_v3-0.4.0+cl-174375304.data-wgs_standard"
GSREF="gs://deepvariant/models/DeepVariant/$MODEL_VERSION/$MODEL_NAME"
GSUTIL=$PREFIX/bin/gsutil
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/models/DeepVariant/$MODEL_VERSION/$MODEL_NAME

mkdir -p $OUTDIR
$GSUTIL cp $GSREF/* $OUTDIR/
