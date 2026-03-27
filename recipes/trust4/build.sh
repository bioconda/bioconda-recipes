#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -Wformat"
LINKPATH="${LDFLAGS}"

if [[ "$(uname -m)" == "x86_64" ]]; then
    # use samtools 0.1.19 as a dependency
    sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
else
    # build the vendored samtools 0.1.19
    sed -i.bak 's/cd samtools-0.1.19 ; make /cd samtools-0.1.19 ; make CC="${CC}" CFLAGS="${CFLAGS} -L${PREFIX}\/lib" LDFLAGS="${LDFLAGS}" LIBPATH="-L${PREFIX}\/lib"/' Makefile
    LINKPATH="${LDFLAGS} -I./samtools-0.1.19 -L./samtools-0.1.19"
fi

sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
rm -rf *.bak

make CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LINKPATH="${LINKPATH}" \
    -j"${CPU_COUNT}"

install -v -m 755 scripts/*.py "${PREFIX}/bin"
install -v -m 755 scripts/*.pl "${PREFIX}/bin"
install -v -m 755 *.pl "${PREFIX}/bin"
install -v -m 755 trust4 fastq-extractor bam-extractor annotator run-trust4 "${PREFIX}/bin"
