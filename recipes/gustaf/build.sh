#!/bin/bash

mkdir -p $PREFIX/bin

if [[ "${target_platform}" == "linux-aarch64" ]]; then

mkdir -p install

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$SRC_DIR/install"

cmake --build build --target install -j "${CPU_COUNT}"

cd install/bin

binaries="\
gustaf \
gustaf_mate_joining \
"

for i in $binaries; do install -v -m 0755 $SRC_DIR/install/bin/$i $PREFIX/bin; done

else

cd bin

binaries="\
gustaf \
gustaf_mate_joining \
"

for i in $binaries; do install -v -m 0755 $SRC_DIR/bin/$i $PREFIX/bin; done

fi
