#!/bin/bash -euo

# Fetch third party dependencies 
# (Git submodules - https://github.com/BenLangmead/bowtie2/blob/a43fa6f43f54989468a294967898f85b9fe4cefa/.gitmodules)
git clone --branch master https://github.com/simd-everywhere/simde-no-tests.git third_party/simde
git clone https://github.com/ch4rr0/libsais third_party/libsais

LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
LDLIBS="-L${PREFIX}/lib -lz -lzstd -ltbb -ltbbmalloc -lpthread"

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3 -L${PREFIX}/lib" \
	-DUSE_SAIS=1

cmake --build build/ --target install -j "${CPU_COUNT}" -v

directories="scripts"

for d in $directories; do
    cp -rf $d ${PREFIX}/bin
done
