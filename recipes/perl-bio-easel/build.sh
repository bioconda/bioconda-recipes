#!/bin/bash

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p $SHARE_DIR/
cp -r src/ $SHARE_DIR/

# Build and install Bio-Easel
export BIO_EASEL_SHARE_DIR=$(pwd)
PATH=$PREFIX/bin:$PATH
perl Makefile.PL INSTALLDIRS=site
make
make test
make install
unset BIO_EASEL_SHARE_DIR

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export BIO_EASEL_SHARE_DIR=$SHARE_DIR" > ${PREFIX}/etc/conda/activate.d/perl-bio-easel.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/perl-bio-easel.sh

echo "unset BIO_EASEL_SHARE_DIR" > ${PREFIX}/etc/conda/deactivate.d/perl-bio-easel.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/perl-bio-easel.sh
