#!/bin/sh

set -o errexit -o nounset

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"
export CXXFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"
export CFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"

BINARY_HOME=${PREFIX}/bin
EVM_HOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

cd plugins/ParaFly
./configure --prefix=${PREFIX} CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS} -fopenmp" CXXFLAGS="${CXXFLAGS} -fopenmp"
make install && cd ${SRC_DIR}

mkdir -p ${EVM_HOME}
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d

cp -Rp ${SRC_DIR}/plugins ${SRC_DIR}/PerlLib ${SRC_DIR}/EvmUtils ${SRC_DIR}/EVidenceModeler ${EVM_HOME}
cp -Rp ${SRC_DIR}/PerlLib ${BINARY_HOME}
cp -Rp ${EVM_HOME}/{EVidenceModeler,EvmUtils,PerlLib,plugins} ${BINARY_HOME}/

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVM_HOME=${EVM_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset EVM_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
