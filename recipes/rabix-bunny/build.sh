#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

# Point to anaconda installed Java
sed -i.bak 's/^loggingConfiguration=/env_prefix="$(dirname $(dirname $basedir))"\
loggingConfiguration=/' rabix
sed -i.bak 's#java#$env_prefix/bin/java#' rabix
rm -f *.bak

# Change defaults to enable running on single machine Docker environments
# Need executor.set_permissions set to true to correctly output cwl.outputs.json
# https://github.com/rabix/bunny/issues/258#issuecomment-302366409
# https://github.com/rabix/bunny/issues/325
# Need better way of managing non-Docker environments in general.
# No longer needed:  https://github.com/rabix/bunny/issues/325#issuecomment-342853956
#sed -i.bak 's/executor.set_permissions=false/executor.set_permissions=true/' config/core.properties

cp -R ./* $outdir/

ln -s $outdir/rabix $PREFIX/bin
