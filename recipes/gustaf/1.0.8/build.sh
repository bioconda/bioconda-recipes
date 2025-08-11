#!/bin/bash

mkdir -p "$PREFIX/bin"

if [[ "${target_platform}" == "linux-aarch64" ]]; then
mkdir -p install

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${SRC_DIR}/install" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

ninja -C build -j "${CPU_COUNT}" gustaf
ninja -C build -j "${CPU_COUNT}" gustaf_mate_joining

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
