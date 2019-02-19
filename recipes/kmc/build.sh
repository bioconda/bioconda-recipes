#!/bin/bash

set -x -e -o pipefail

echo HERE IS THE ENV
env

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS}"

chmod u+x ${SRC_DIR}/configure
chmod u+x ${SRC_DIR}/build-aux/ar-lib
chmod u+x ${SRC_DIR}/build-aux/compile
chmod u+x ${SRC_DIR}/build-aux/config.guess
chmod u+x ${SRC_DIR}/build-aux/config.sub
chmod u+x ${SRC_DIR}/build-aux/depcomp
chmod u+x ${SRC_DIR}/build-aux/install-sh
chmod u+x ${SRC_DIR}/build-aux/ltmain.sh
chmod u+x ${SRC_DIR}/build-aux/missing
chmod u+x ${SRC_DIR}/build-aux/test-driver

cp README.md README

mkdir -p build
pushd build

${SRC_DIR}/configure --prefix=$PREFIX
make -j${CPU_COUNT} install
popd

mv $PREFIX/bin/kmc_prog $PREFIX/bin/kmc
mv $PREFIX/bin/kmc_tools_prog $PREFIX/bin/kmc_tools
mv $PREFIX/bin/kmc_dump_prog $PREFIX/bin/kmc_dump
