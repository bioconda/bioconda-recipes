#!/bin/bash -euo

# Fetch third party dependencies 
# (Git submodules - https://github.com/BenLangmead/bowtie2/blob/a43fa6f43f54989468a294967898f85b9fe4cefa/.gitmodules)
git clone --branch master https://github.com/simd-everywhere/simde-no-tests.git third_party/simde
git clone https://github.com/ch4rr0/libsais third_party/libsais

LDFLAGS=""
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3" CPP="${CXX} -I${PREFIX}/include" CC="${CC} -L${PREFIX}/lib" \
	CFLAGS="${CFLAGS} -O3" LDLIBS="-L$PREFIX/lib -lz -lzstd -lpthread" \
	WITH_ZSTD=1 USE_SRA=1 USE_SAIS_OPENMP=1

binaries="\
bowtie2 \
bowtie2-align-l \
bowtie2-align-s \
bowtie2-build \
bowtie2-build-l \
bowtie2-build-s \
bowtie2-inspect \
bowtie2-inspect-l \
bowtie2-inspect-s \
"
directories="scripts"
pythonfiles="bowtie2-build bowtie2-inspect"

for i in $binaries; do
    cp -rf $i ${PREFIX}/bin && chmod 755 $PREFIX/bin/${i}
done

for d in $directories; do
    cp -rf $d ${PREFIX}/bin
done

make clean
