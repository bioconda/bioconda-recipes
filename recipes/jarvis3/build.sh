#!/bin/bash

set -xe

export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

cd src 
make -j"${CPU_COUNT}" CC=$CC CFLAGS="$CFLAGS -fcommon"
mkdir -p ${PREFIX}/bin

mv extra/ ${PREFIX}/bin
mv JARVIS3.sh ${PREFIX}/bin
mv JARVIS3 ${PREFIX}/bin

cd ${PREFIX}/bin
sed -i.bak 's/ \.\// /g; s/\"\.\//"/g; s/make/make CC=$CC CFLAGS="$CFLAGS -fcommon"/g' JARVIS3.sh
chmod +x JARVIS3.sh
JARVIS3.sh --install
