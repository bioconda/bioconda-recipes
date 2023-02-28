#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -t $outdir QoRTs.jar scripts/QoRTs.sh scripts/qortsGenMultiQC.R

# Symlink the executable wrapper as qorts
ln -s $outdir/QoRTs.sh $PREFIX/bin/qorts

# Symlink provided script
ln -s $outdir/qortsGenMultiQC.R $PREFIX/bin/qortsGenMultiQC.R

chmod 0755 "${PREFIX}/bin/qorts"
