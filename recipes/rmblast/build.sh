#!/bin/bash
set -euxo pipefail

cd ${SRC_DIR}/c++/

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    export LDFLAGS="${LDFLAGS} -Wl,-as-needed"
fi

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -lz -lbz2"
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
    export CPP_FOR_BUILD=${CPP}
fi

export LIB_INSTALL_DIR="${PREFIX}/lib/ncbi-blast+"

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
  export CONFIG_ARGS="--with-openmp --with-hard-runpath --with-runpath=${LIB_INSTALL_DIR}"
else
  export CONFIG_ARGS="--without-openmp"
fi

# not building with boost as it's only used for unit tests
./configure \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    --prefix=${PREFIX} \
    --with-64 \
    --with-mt \
    --without-dll \
    --with-flat-makefile \
    --without-caution \
    --without-boost \
    --without-lzo \
    --without-zstd \
    --without-debug \
    --with-experimental=Int8GI \
    --without-openssl \
    --with-strip \
    --without-vdb \
    --with-z=${PREFIX} \
    --with-bz2=${PREFIX} \
    --without-krb5 \
    --without-gnutls \
    --without-sse42 \
    --without-gcrypt \
    --without-pcre \
    ${CONFIG_ARGS}

projects="algo/blast/ app/ objmgr/ objtools/align_format/ objtools/blast/"
cd ReleaseMT

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -s ${SRC_DIR}/c++/ReleaseMT/lib ${LIB_INSTALL_DIR}

cd build
make -j1 -f Makefile.flat all_projects="${projects}"

# remove temporary link
rm ${LIB_INSTALL_DIR}

mkdir -p ${PREFIX}/bin ${LIB_INSTALL_DIR}
chmod +x ${SRC_DIR}/c++/ReleaseMT/bin/*
cp ${SRC_DIR}/c++/ReleaseMT/bin/* ${PREFIX}/bin/
cp ${SRC_DIR}/c++/ReleaseMT/lib/* ${LIB_INSTALL_DIR}

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/update_blastdb.pl
# Patches to enable this script to work better in bioconda
sed -i.bak 's/mktemp.*/mktemp`/; s/exit 1/exit 0/; s/^export PATH=\/bin:\/usr\/bin:/\#export PATH=\/bin:\/usr\/bin:/g' $PREFIX/bin/get_species_taxids.sh

#extra log to check all exe are present
ls -s ${PREFIX}/bin/
