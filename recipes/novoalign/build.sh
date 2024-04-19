#!/bin/bash
set -eux

mkdir -p "${PREFIX}/bin"

if [ $(uname -m) == "x86_64" ]; then
    ARCH_OPTS="-m64"
else
    ARCH_OPTS=""
fi

# Compile and install novo2maq
make -C novo2maq -j${CPU_COUNT} \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS} ${CPPFLAGS} -g -Wall -O2 ${ARCH_OPTS} ${LDFLAGS}" \
    CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} -g -Wall -O2 ${ARCH_OPTS} -fpermissive ${LDFLAGS}"
cp novo2maq/novo2maq ${PREFIX}/bin

# Install all executables
find . -maxdepth 1 -perm -111 -type f -exec cp {} ${PREFIX}/bin ';'

# Install license script
cp ${RECIPE_DIR}/novoalign-license-register.sh ${PREFIX}/bin/novoalign-license-register

# Install documentation
DOC_DIR=${PREFIX}/share/doc/novoalign
mkdir -p ${DOC_DIR}
cp *.pdf *.txt ${RECIPE_DIR}/license.txt ${DOC_DIR}
