#!/bin/bash
set -euxo pipefail

patch -p1 < $RECIPE_DIR/isb-2.9.0+-rmblast-p2.patch

cd $SRC_DIR/c++/

export CFLAGS="$CFLAGS -Ofast"
export CXXFLAGS="$CXXFLAGS -Ofast"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CC_FOR_BUILD=$CC

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    LDFLAGS="$LDFLAGS -Wl,-as-needed"
fi

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib -lz -lbz2"
else
    export CPP_FOR_BUILD=$CPP
fi

LIB_INSTALL_DIR=$PREFIX/lib/ncbi-blast+

# with/without options:
#
# dll: enable dynamic linking
# mt: enable multi-threading
# -autodep: no automatic dependency build (one time build)
# -makefile-auto-update: no rebuild of makefile (one time build)
# flat-makefile: use single makefile
# -caution: disable configure script warnings
# -dbapi: don't build database connectivity libs
# -lzo: don't add lzo support
# runpath: set runpath for installed $PREFIX location
# hard-runpath: disable new dtags (disallow LD_LIBRARY_PATH override on Linux)
# -debug: disable debug
# strip: remove debugging symbols (size!)
# -vdb: disable VDB/SRA toolkit
# z: set zlib
# bz2: set libbz2
# boost: set boost
# -openssl: disable openssl
# -gcrypt: disable gcrypt (needed on OSX)
# gnutls: set gnutls (preferred over openssl for -remote support)
# nettle: set nettle
# -krb5: disable kerberos (needed on OSX)

# Fixes building on Linux
export AR="${AR} rcs"

if [ `uname` == Linux ]; then
  CONFIG_ARGS="--without-openssl --with-gnutls=$PREFIX"
else
  CONFIG_ARGS="--without-gnutls --with-openssl=$PREFIX"
fi

# not building with boost as it's only used for unit tests
./configure \
    --with-dll \
    --with-mt \
    --without-autodep \
    --without-makefile-auto-update \
    --with-flat-makefile \
    --without-caution \
    --without-dbapi \
    --without-lzo \
    --with-hard-runpath \
    --with-runpath=$LIB_INSTALL_DIR \
    --without-debug \
    --with-strip \
    --without-vdb \
    --with-z=$PREFIX \
    --with-bz2=$PREFIX \
    --with-nettle=$PREFIX \
    --without-krb5 \
    --without-sse42 \
    --without-gcrypt $CONFIG_ARGS

projects="algo/blast/ app/ objmgr/ objtools/align_format/ objtools/blast/"
cd ReleaseMT

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s $SRC_DIR/c++/ReleaseMT/lib $LIB_INSTALL_DIR

cd build
make -j${CPU_COUNT} -f Makefile.flat all_projects="$projects"

# remove temporary link
rm $LIB_INSTALL_DIR

mkdir -p $PREFIX/bin $LIB_INSTALL_DIR
rm $SRC_DIR/c++/ReleaseMT/bin/*_unit_test
cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
cp $SRC_DIR/c++/ReleaseMT/lib/* $LIB_INSTALL_DIR

chmod +x $PREFIX/bin/*
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/update_blastdb.pl
# Patches to enable this script to work better in bioconda
sed -i.bak 's/mktemp.*/mktemp`/; s/exit 1/exit 0/; s/^export PATH=\/bin:\/usr\/bin:/\#export PATH=\/bin:\/usr\/bin:/g' $PREFIX/bin/get_species_taxids.sh
