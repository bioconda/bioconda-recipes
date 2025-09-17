#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LC_ALL="en_US.UTF-8"

export SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/easel

mkdir -p $SHARE_DIR/
cp -rf src/ $SHARE_DIR/

# Build and install Bio-Easel
export BIO_EASEL_SHARE_DIR="$(pwd)"
export PATH="$PREFIX/bin:$PATH"

perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1
make -j"${CPU_COUNT}"
make test
make install
unset BIO_EASEL_SHARE_DIR

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export BIO_EASEL_SHARE_DIR=$SHARE_DIR" > ${PREFIX}/etc/conda/activate.d/perl-bio-easel.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/perl-bio-easel.sh

echo "unset BIO_EASEL_SHARE_DIR" > ${PREFIX}/etc/conda/deactivate.d/perl-bio-easel.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/perl-bio-easel.sh
