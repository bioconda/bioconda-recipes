#!/bin/bash
set -euo pipefail

# Patch the Makefile to use conda-provided htslib and zstd headers
# instead of the bundled (empty) git submodules
sed -i.bak \
    -e "s|HTS_OPTS = -I\$(HTS_DIR)/htslib/|HTS_OPTS = -I${PREFIX}/include/htslib|" \
    -e "s|ZSTD_OPTS = -I\$(ZSTD_DIR)/lib/|ZSTD_OPTS = -I${PREFIX}/include|" \
    Makefile
rm -f Makefile.bak

# Build all programs, overriding variables so make uses conda's htslib and
# zstd instead of trying to build them from the (empty) submodule directories.
#
#   HTS_LIB / ZSTD_LIB  – point to existing files; make skips their build rules
#   HTS_OBJS / ZSTD_OBJS – empty so no lib-copy order-only prerequisites fire
#   R_PATH               – use conda prefix for -L and -rpath
make onebam ONEview ONEstat seqstat seqconvert \
    CFLAGS="${CFLAGS} -I${PREFIX}/include/htslib" \
    HTS_LIB="${PREFIX}/lib/libhts${SHLIB_EXT}" \
    ZSTD_LIB="${PREFIX}/lib/libzstd${SHLIB_EXT}" \
    HTS_OBJS="" \
    ZSTD_OBJS="" \
    R_PATH="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
cp onebam ONEview ONEstat seqstat seqconvert "${PREFIX}/bin/"
