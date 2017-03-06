#!/usr/bin/env  bash

set -x -e

# Configure

# This recipe is adapted from the recipe available at biobuilds
# https://github.com/lab7/biobuilds/tree/master/cufflinks/2.2.1

build_os=$(uname -s)

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export EIGEN_CPPFLAGS="-I${PREFIX}/include/eigen3"
export PKG_CONFIG_PATH="${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"

export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib
export BOOSTLIBDIR=${PREFIX}/lib
export LIBS='-lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/eigen3 -I${PREFIX}/include/bam"
export CXXFLAGS="${CXXFLAGS} -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="${LDFLAGS} -L${BOOST_LIBRARY_DIR} -lboost_filesystem -lboost_system"


if [ "$build_os" == 'Darwin' ]; then
    CFLAGS="${CFLAGS} -Wno-deprecated-register -Wno-unused-variable"
    CXXFLAGS="${CXXFLAGS} -Wno-deprecated-register -Wno-unused-variable"

    MACOSX_VERSION_MIN="10.8"
    CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Make sure we use the same C++ standard library as boost
    # NOTE: need to set this CFLAGS as well, as ./configure and the resulting
    # Makefile seem to ignore CXXFLAGS in some cases.
    CFLAGS="${CFLAGS} -stdlib=libc++"
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

CFLAGS="${CFLAGS} -static-libstdc++"
CXXFLAGS="${CXXFLAGS} -static-libstdc++"
LDFLAGS="${LDFLAGS} -static-libstdc++"


cp -f "${RECIPE_DIR}/config.guess" "${SRC_DIR}/build-aux/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${SRC_DIR}/build-aux/config.sub"

[ -f Makefile ] && make distclean

env BAM_ROOT="${PREFIX}/include/bam/" \
	ZLIB_HOME="${PREFIX}" \
	CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
        EIGEN_CPPFLAGS="${EIGEN_CPPFLAGS}" \
        CPPFLAGS="${CPPFLAGS}" \
    	./configure --prefix="${PREFIX}" \
    	--with-zlib="${PREFIX}" \
    	--with-boost="${PREFIX}"

make

make install
