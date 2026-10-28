#!/bin/bash

# parasail bundles a test (tests/test_verify_traces.c) with an int* -> int8_t*
# pointer mismatch. GCC 14+ promotes -Wincompatible-pointer-types (and related
# C diagnostics) to errors by default, which breaks the bundled test build even
# though ksw only links libparasail.a. Downgrade these back to warnings so the
# library and binary build cleanly. parasail's CMake configure inherits CFLAGS
# from the environment.
export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion"

install -d "${PREFIX}/bin"

make_args=(
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    PREFIX="${PREFIX}/bin"
    PKG_VERSION="${PKG_VERSION}"
)

# Build the ksw2 and parasail subdirectories (including libparasail.a) before
# linking ksw. A single parallel `make all` races and can try to link ksw
# before libparasail.a exists (ld: cannot find -lparasail).
make "${make_args[@]}" -j"${CPU_COUNT}" clean
make "${make_args[@]}" -j"${CPU_COUNT}" src/ksw2/ src/parasail/build
make "${make_args[@]}" -j"${CPU_COUNT}" install
