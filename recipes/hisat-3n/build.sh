#!/bin/bash
set -x

git clone https://github.com/simd-everywhere/simde-no-tests simde

make -j ${CPU_COUNT} \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CPP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# copy binaries and python scripts
# TODO: can hisat-3n depend on hisat2 in the meta.yaml?
mkdir -p "${PREFIX}/bin"
for i in \
    hisat-3n \
    hisat-3n-build \
    hisat-3n-table \
    hisat2-build \
    hisat2-build-l \
    hisat2-build-s \
    hisat2-align-l \
    hisat2-align-s
do
    cp "${i}" "${PREFIX}/bin/"
    chmod +x "${PREFIX}/bin/${i}"
done
