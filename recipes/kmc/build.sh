#!/bin/bash

set -efu -o pipefail

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

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
make install
popd


