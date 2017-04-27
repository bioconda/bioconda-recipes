#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# Point to anaconda installed Java
sed -i.bak 's/^loggingConfiguration=/env_prefix="$(dirname $(dirname $basedir))"\
loggingConfiguration=/' rabix
sed -i.bak 's#java#$env_prefix/bin/java#' rabix
rm -f *.bak

cp -R ./* $outdir/

ln -s $outdir/rabix $PREFIX/bin
