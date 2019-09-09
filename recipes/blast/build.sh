#!/bin/bash
set -euxo pipefail

cd $SRC_DIR/c++/

export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"
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
# -openssl: disable openssl
# -gcrypt: disable gcrypt (needed on OSX)
# -krb5: disable kerberos (needed on OSX)

# Fixes building on Linux
export AR="${AR} rcs" 

./configure \
    --with-dll \
    --with-mt \
    --with-openmp \
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
    --with-z=$PREFIX \
    --without-krb5 \
    --without-openssl \
    --without-gnutls \
    --without-gcrypt

apps="blastp.exe blastn.exe blastx.exe tblastn.exe tblastx.exe psiblast.exe"
apps="$apps rpsblast.exe rpstblastn.exe makembindex.exe segmasker.exe"
apps="$apps dustmasker.exe windowmasker.exe deltablast.exe makeblastdb.exe" 
apps="$apps blastdbcmd.exe blastdb_aliastool.exe convert2blastmask.exe"
apps="$apps blastdbcheck.exe makeprofiledb.exe blast_formatter.exe"
cd ReleaseMT

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s $SRC_DIR/c++/ReleaseMT/lib $LIB_INSTALL_DIR

cd build
make -j${CPU_COUNT} -f Makefile.flat $apps

# remove temporary link
rm $LIB_INSTALL_DIR

mkdir -p $PREFIX/bin $LIB_INSTALL_DIR
cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
cp $SRC_DIR/c++/ReleaseMT/lib/* $LIB_INSTALL_DIR

chmod +x $PREFIX/bin/*
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/update_blastdb.pl
# Patches to enable this script to work better in bioconda
sed -i.bak 's/mktemp.*/mktemp`/; s/exit 1/exit 0/; s/^export PATH=\/bin:\/usr\/bin:/\#export PATH=\/bin:\/usr\/bin:/g' $PREFIX/bin/get_species_taxids.sh
