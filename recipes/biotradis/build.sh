#!/bin/sh
set -x -e
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cp -r bin/* $PREFIX/bin
cp -r lib/* $PREFIX/lib

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d

echo "export PERL5LIB=$PERL5LIB:$PREFIX/lib" > ${PREFIX}/etc/conda/activate.d/biotradis-perl5lib.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/biotradis-perl5lib.sh

echo "unset PERL5LIB" > ${PREFIX}/etc/conda/deactivate.d/biotradis-perl5lib.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/biotradis-perl5lib.sh
