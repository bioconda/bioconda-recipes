#!/bin/bash
# Builds fast-beagle against the htslib in the host environment. The Makefile
# appends its fixed floating-point flags after the compiler's CFLAGS. WERROR=
# keeps warnings from conda's compilers, such as GCC's -Warray-bounds at the
# -O3 that linux-aarch64 uses, from failing the build.
set -euo pipefail
make -j"${CPU_COUNT}" install PREFIX="${PREFIX}" HTSLIB_PREFIX="${PREFIX}" WERROR=
