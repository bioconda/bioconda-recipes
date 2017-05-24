#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# Point to anaconda installed Java
sed -i.bak 's/^loggingConfiguration=/env_prefix="$(dirname $(dirname $basedir))"\
loggingConfiguration=/' rabix
sed -i.bak 's#java#$env_prefix/bin/java#' rabix
rm -f *.bak

# Change defaults to enable running on single machine non-Docker environments
# https://github.com/rabix/bunny/issues/258#issuecomment-302366409
sed -i.bak 's/executor.set_permissions=true/executor.set_permissions=false/' config/core.properties
sed -i.bak 's/resource.fitter.enabled=false/resource.fitter.enabled=true/' config/core.properties

cp -R ./* $outdir/

ln -s $outdir/rabix $PREFIX/bin
