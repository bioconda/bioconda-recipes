#!/bin/bash
set -eu -o pipefail

CXXFLAGS="${CXXFLAGS} -fPIC"

sed -i '1s/.*/CC=${CC}/' SeqLib/fermi-lite/Makefile

echo "######## DEBUG START ########"

head -n1 SeqLib/fermi-lite/Makefile
sed -i "1s/.*/CC=${CC}/" SeqLib/fermi-lite/Makefile
head -n1 SeqLib/fermi-lite/Makefile

echo "######## DEBUG STOP ########"

./configure
make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
