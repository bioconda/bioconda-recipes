#!/usr/bin/env bash
set -euxo pipefail

# The vendored htslib and cephes Makefiles both hardcode `CC = gcc`, and a
# makefile assignment beats the environment in GNU Make, so neither picks up
# conda's target-prefixed compiler on its own. Give them a `gcc` to find.
ln -sf "${CC}" "${BUILD_PREFIX}/bin/gcc"

# Same two sub-builds, for headers and libraries: CPATH and LIBRARY_PATH are
# read by the compiler itself rather than passed as flags, so they survive a
# sub-make that would otherwise drop CPPFLAGS/LDFLAGS.
export CPATH="${PREFIX}/include:${CPATH:-}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH:-}"

make -j"${CPU_COUNT}" HipSTR-MT

install -d "${PREFIX}/bin"
install -m 755 HipSTR-MT "${PREFIX}/bin/HipSTR-MT"
