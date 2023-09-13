#!/bin/bash
set -eu

# Compile and install novo2maq
make -C novo2maq CC="$CC" CXX="$CXX" CFLAGS="-g -Wall -O2 -m64 -fpermissive -isystem $PREFIX/include" LIBS="-L${PREFIX}/lib -lz -lm"
cp novo2maq/novo2maq ${PREFIX}/bin

# Install all executables
find . -maxdepth 1 -perm -111 -type f -exec cp {} ${PREFIX}/bin ';'

# Install license script
cp ${RECIPE_DIR}/novoalign-license-register.sh ${PREFIX}/bin/novoalign-license-register

# Install documentation
DOC_DIR=${PREFIX}/share/doc/novoalign
mkdir -p ${DOC_DIR}
cp *.pdf *.txt ${RECIPE_DIR}/license.txt ${DOC_DIR}
