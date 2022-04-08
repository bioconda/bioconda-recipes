#!/bin/bash

BINDIR="${PREFIX}/bin"
mkdir -p "${BINDIR}"

# build FastTree
"${CC}" ${CPPFLAGS} ${CFLAGS} \
    -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall \
    -o "${BINDIR}"/FastTree \
    FastTree-${PKG_VERSION}.c \
    ${LDFLAGS} -lm



# Build FastTreeMP on Linux
if [ "$(uname)" == "Linux" ]; then
    "${CC}" ${CPPFLAGS} ${CFLAGS} \
        -DOPENMP -fopenmp -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall \
        -o "${BINDIR}"/FastTreeMP \
        FastTree-${PKG_VERSION}.c \
        ${LDFLAGS} -lm
fi

cp "${BINDIR}/FastTree" "${BINDIR}"/fasttree
