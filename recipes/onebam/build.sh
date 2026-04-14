#!/bin/bash
set -euo pipefail

# Patch the Makefile to use conda-provided htslib and zstd headers
sed -i.bak \
    -e "s|HTS_OPTS = -I\$(HTS_DIR)/htslib/|HTS_OPTS = -I${PREFIX}/include -I${PREFIX}/include/htslib|" \
    -e "s|ZSTD_OPTS = -I\$(ZSTD_DIR)/lib/|ZSTD_OPTS = -I${PREFIX}/include|" \
    Makefile
rm -f Makefile.bak

make onebam ONEview ONEstat seqstat seqconvert \
    CFLAGS="${CFLAGS} -I${PREFIX}/include -I${PREFIX}/include/htslib" \
    HTS_LIB="${PREFIX}/lib/libhts${SHLIB_EXT}" \
    ZSTD_LIB="${PREFIX}/lib/libzstd${SHLIB_EXT}" \
    HTS_LIBS="-L${PREFIX}/lib -lhts" \
    ZSTD_LIBS="-L${PREFIX}/lib -lzstd" \
    LIBS="-lpthread -lm -lbz2 -llzma -lcurl -lz" \
    HTS_OBJS="" \
    ZSTD_OBJS="" \
    R_PATH="${LDFLAGS}"

mkdir -p "${PREFIX}/bin"
install -m 755 onebam ONEview ONEstat seqstat seqconvert "${PREFIX}/bin/"
