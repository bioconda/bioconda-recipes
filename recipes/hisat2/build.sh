#!/bin/bash

# The patch does not move the VERSION file on OSX. Let's make sure it's moved.
mv VERSION{,.txt} || true

make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CPP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# copy binaries and python scripts
mkdir -p "${PREFIX}/bin"
for i in \
    hisat2 \
    hisat2-align-l \
    hisat2-align-s \
    hisat2-build \
    hisat2-build-l \
    hisat2-build-s \
    hisat2-inspect \
    hisat2-inspect-l \
    hisat2-inspect-s \
    *.py
do
    cp "${i}" "${PREFIX}/bin/"
    chmod +x "${PREFIX}/bin/${i}"
done
