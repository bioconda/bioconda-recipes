#!/bin/bash
set -ef -o pipefail

mkdir -p "$PREFIX/bin"

rm -rf bamtools
mkdir -p bamtools/include
ln -sf $PREFIX/lib bamtools/
ln -sf $PREFIX/include/bamtools/api bamtools/include/
ln -sf $PREFIX/include/bamtools/shared bamtools/include/

if [[ "$(uname -s)"  == "Linux" ]]; then
	sed -i.bak 's|ZLIB REQUIRED STATIC|ZLIB REQUIRED|' CMakeLists.txt
	rm -rf *.bak
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_STATIC_LIBRARY_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}"

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/src/bam-read "$PREFIX/bin"
