#!/bin/bash
set -euo pipefail

# YAME's vendored htslib Makefile hard-resets CFLAGS/CPPFLAGS, so conda's
# "-isystem $PREFIX/include" flags don't reach it and zlib.h isn't found. CPATH /
# LIBRARY_PATH are honored directly by the compiler driver, bypassing every
# Makefile's flag handling, so headers (zlib.h) and libs (-lz) resolve in all
# three build layers (methscope, YAME, htslib).
export CPATH="${PREFIX}/include${CPATH:+:${CPATH}}"
export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"

# XGB_PREFIX points the Makefile at the build env's include/ and lib/ for
# libxgboost. The Makefile bakes -Wl,-rpath,$XGB_PREFIX/lib; conda-build's
# post-processing relocates that to an $ORIGIN-relative RPATH, so the installed
# binary finds libxgboost.so without activating any env.
make CC="${CC}" XGB_PREFIX="${PREFIX}"

# Portable install: macOS ships BSD install (no GNU `-D`; the bundled `-Dm755`
# form misparses and fails with EX_OSERR). mkdir + `-m 0755` works on both.
mkdir -p "${PREFIX}/bin"
install -m 0755 methscope "${PREFIX}/bin/methscope"
