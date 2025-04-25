#!/bin/bash
set -euxo pipefail

cd ${SRC_DIR}/c++/

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    export LDFLAGS="${LDFLAGS} -Wl,-as-needed"
fi

if [[ `uname` == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -lz -lbz2"
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
    export CPP_FOR_BUILD="${CPP}"
fi

export LIB_INSTALL_DIR="${PREFIX}/lib64/ncbi-blast+"

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

# Source path
BLAST_SRC_DIR="$SRC_DIR/c++"
# Work directory
RESULT_PATH="$BLAST_SRC_DIR/Release"

if [[ `uname` == "Linux" ]]; then
	export CONFIG_ARGS="--with-runpath=\"${LIB_INSTALL_DIR}\" --with-openmp --with-hard-runpath --with-dll --without-zstd"
	if [[ "$(uname -m)" == "x86_64" ]]; then
            export CONFIG_ARGS="${CONFIG_ARGS} --with-64"
	fi
else
	export CONFIG_ARGS='--without-openmp --without-dll --without-gcrypt'
fi

# not building with boost as it's only used for unit tests
./configure CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    --prefix="${PREFIX}" \
    --with-mt \
    --with-build-root="${RESULT_PATH}" \
    --with-bin-release \
    --with-flat-makefile \
    --without-autodep \
    --without-makefile-auto-update \
    --without-caution \
    --without-boost \
    --without-lzo \
    --without-debug \
    --with-experimental=Int8GI \
    --with-strip \
    --with-vdb="${PREFIX}" \
    --with-z="${PREFIX}" \
    --with-bz2="${PREFIX}" \
    --with-sqlite3="${PREFIX}" \
    --without-krb5 \
    --without-gnutls \
    --without-sse42 \
    --without-pcre \
    ${CONFIG_ARGS}

projects="algo/blast/ app/ objmgr/ objtools/align_format/ objtools/blast/"
cd Release

# The "datatool" binary needs the libs at build time, create
# link from final install path to lib build dir:
ln -sf ${SRC_DIR}/c++/Release/lib ${LIB_INSTALL_DIR}

cd build
make -f Makefile.flat all_projects="${projects}" -j"${CPU_COUNT}"

# remove temporary link
rm -rf ${LIB_INSTALL_DIR}

mkdir -p "${PREFIX}/bin" "${LIB_INSTALL_DIR}"
install -v -m 0755 ${SRC_DIR}/c++/Release/bin/* "${PREFIX}/bin"
cp -rf ${SRC_DIR}/c++/Release/lib/* "${LIB_INSTALL_DIR}"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/update_blastdb.pl
# Patches to enable this script to work better in bioconda
sed -i.bak 's/mktemp.*/mktemp`/; s/exit 1/exit 0/; s/^export PATH=\/bin:\/usr\/bin:/\#export PATH=\/bin:\/usr\/bin:/g' $PREFIX/bin/get_species_taxids.sh
rm -rf $PREFIX/bin/*.bak

#extra log to check all exe are present
ls -s ${PREFIX}/bin/
