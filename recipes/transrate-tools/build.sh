#!/bin/bash
set -ef -o pipefail

mkdir -p "$PREFIX/bin"

rm -rf bamtools
mkdir -p bamtools/include
ln -sf $BUILD_PREFIX/lib bamtools/
ln -sf $BUILD_PREFIX/include/bamtools/api bamtools/include/
ln -sf $BUILD_PREFIX/include/bamtools/shared bamtools/include/

if [[ "${target_platform}"  == "linux-aarch64" ]]; then
	sed -i "43c \\\  find_package (ZLIB REQUIRED)" CMakeLists.txt
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_STATIC_LIBRARY_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}"

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/src/bam-read "$PREFIX/bin"
