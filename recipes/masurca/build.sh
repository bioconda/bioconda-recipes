#!/bin/bash
set -x -e

export BOOST_ROOT="${PREFIX}"
export DEST="${PREFIX}"
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O3 -fstack-protector"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -std=gnu90"
export CXXFLAGS="${CXXFLAGS} -O3"
export LC_ALL=en_US.UTF-8

./install.sh

ls ${SRC_DIR}
ls ${SRC_DIR}/bin
ls ${SRC_DIR}/src
