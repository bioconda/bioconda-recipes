#!/bin/sh
set -x -e
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $PREFIX/bin
mkdir -p $SHARE_DIR/lib

chmod 755 *.pl
cp *.pl $PREFIX/bin
cp *.pm $SHARE_DIR/lib

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d

echo "export PERL5LIB=$PERL5LIB:$SHARE_DIR/lib" > ${PREFIX}/etc/conda/activate.d/sequip-perl5lib.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/sequip-perl5lib.sh

echo "unset PERL5LIB" > ${PREFIX}/etc/conda/deactivate.d/sequip-perl5lib.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/sequip-perl5lib.sh
