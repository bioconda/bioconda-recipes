#!/bin/bash

sed -i.bak 's|2.8.9|3.5|' CMakeLists.txt
sed -i.bak 's|2.8.12|3.5|' lib/mmseqs/CMakeLists.txt
sed -i.bak 's|2.8.4|3.5|' lib/mmseqs/lib/tinyexpr/CMakeLists.txt

if [[ ! ("$(uname -s)" == "Linux" && "$(uname -m)" == "aarch64") ]]; then
    sed -i '12c\#include <cstdint>' lib/mmseqs/src/prefiltering/Indexer.h
	sed -i '3c\#include <cstdint>' lib/mmseqs/src/commons/Util.h
	sed -i '3c\#include <cstdint>' lib/mmseqs/src/commons/Debug.h
	sed -i '168c\return {pattern, static_cast<unsigned int>(pair.second)};' lib/mmseqs/src/commons/Sequence.cpp
    sed -i '4a\target_compile_definitions(ksw2 PRIVATE NEON=1)' lib/mmseqs/lib/ksw2/CMakeLists.txt
	git clone https://github.com/DLTcollab/sse2neon.git
	rm -rf lib/mmseqs/lib/simd/sse2neon.h
	cp -f sse2neon/sse2neon.h lib/mmseqs/lib/simd/
fi

mkdir -p build
cd build

if [[ `uname -m` == "aarch64" || `uname -m` == "arm64" ]]; then
	cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DVERSION_OVERRIDE="${PKG_VERSION}" -DHAVE_NEON=1 -DHAVE_TESTS=0 -DCMAKE_CXX_FLAGS="-O3 -Wno-error=strict-aliasing" ..
else
	cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DVERSION_OVERRIDE="${PKG_VERSION}" -DHAVE_SSE4_1=1 -DHAVE_TESTS=0 -DCMAKE_CXX_FLAGS="-O3 -Wno-error=strict-aliasing" ..
fi

cmake --build . --target install -j 1
make install
