#!/bin/bash

export RCSBROOT=${SRC_DIR}

ln -s ${CC} ${BUILD_PREFIX}/bin/gcc
ln -s ${CXX} ${BUILD_PREFIX}/bin/c++
ln -s ${CXX} ${BUILD_PREFIX}/bin/cxx
ln -s ${GXX} ${BUILD_PREFIX}/bin/g++

cd ${RCSBROOT}/cifparse-obj-v7.0
sed -i 's/mv /cp /' Makefile

cd ${RCSBROOT}
sed -i 's|./data/binary|\${RCSBROOT}/data/binary|g' binary.sh

cd ${RCSBROOT}
make binary -j"${CPU_COUNT}"

unlink ${BUILD_PREFIX}/bin/gcc
unlink ${BUILD_PREFIX}/bin/c++
unlink ${BUILD_PREFIX}/bin/cxx
unlink ${BUILD_PREFIX}/bin/g++

install -d ${PREFIX}/bin
install ${RCSBROOT}/bin/* ${PREFIX}/bin
install -d ${PREFIX}/data
install -m 644 ${RCSBROOT}/data/* ${PREFIX}/data
