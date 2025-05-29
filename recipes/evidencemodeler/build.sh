#!/bin/bash

set -o errexit -o nounset

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export CFLAGS="${CFLAGS} -O3"

BINARY_HOME="${PREFIX}/bin"
export EVM_HOME="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"
export LC_ALL="en_US.UTF-8"

sed -i.bak 's|v2.0.0|v2.1.0|' EVidenceModeler
rm -rf *.bak
sed -i.bak 's|-m64||' ParaFly/configure.ac
rm -rf ParaFly/*.bak
sed -i.bak 's|$accession >|'$accession' >|' EvmUtils/convert_EVM_outputs_to_GFF3.pl
rm -rf EvmUtils/*.bak

OS=$(uname -s)
ARCH=$(uname -m)

cd plugins/ParaFly
autoreconf -if
./configure --prefix="${PREFIX}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -fopenmp" \
	LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	--disable-option-checking --enable-silent-rules \
	--disable-dependency-tracking

if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
	sed -i.bak 's|-m64||' Makefile
fi

sed -i.bak 's|-O2|-O3|' Makefile
rm -rf *.bak

make install -j"${CPU_COUNT}" && cd "${SRC_DIR}"

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
