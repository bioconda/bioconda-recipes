#!/bin/bash

# parasail (bundled and built via CMake) compiles a test, tests/test_verify_traces.c,
# that assigns an `int *` to an `int8_t *`. GCC 14+ promotes -Wincompatible-pointer-types
# (and related C diagnostics) to hard errors by default, which breaks the bundled test
# build even though ksw only links libparasail.a. Downgrade these back to warnings so the
# library and the ksw binary build cleanly. parasail's CMake configure inherits CFLAGS
# from the environment.
export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion"

install -d "${PREFIX}/bin"
make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    PREFIX="${PREFIX}/bin" \
    PKG_VERSION="${PKG_VERSION}" \
    -j"${CPU_COUNT}" \
    clean all install
