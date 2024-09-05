#!/bin/bash

set -euxo pipefail

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export RCSBROOT=${SRC_DIR}
export CPU_COUNT=1

ln -s ${CC} ${BUILD_PREFIX}/bin/gcc
ln -s ${CXX} ${BUILD_PREFIX}/bin/c++
ln -s ${CXX} ${BUILD_PREFIX}/bin/cxx
ln -s ${GXX} ${BUILD_PREFIX}/bin/g++

cd ${SRC_DIR}/cifparse-obj-v7.0 && sed -i 's/mv /cp /g' Makefile
cd ${SRC_DIR} && sed -i 's|./data/binary|${SRC_DIR}/data/binary|g' binary.sh
cd ${SRC_DIR} && make binary -j"${CPU_COUNT}"

unlink ${BUILD_PREFIX}/bin/gcc
unlink ${BUILD_PREFIX}/bin/c++
unlink ${BUILD_PREFIX}/bin/cxx
unlink ${BUILD_PREFIX}/bin/g++

install -d ${PREFIX}/bin
install ${SRC_DIR}/bin/* ${PREFIX}/bin
install -d ${PREFIX}/data
install -m 644 ${SRC_DIR}/data/* ${PREFIX}/data
