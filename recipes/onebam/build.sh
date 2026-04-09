#!/bin/bash
set -euo pipefail

case "$(uname -s)" in
    Darwin)
        shared_ext=".dylib"
        ;;
    *)
        shared_ext=".so"
        ;;
esac

hts_lib=$(find "${PREFIX}/lib" -maxdepth 1 -type f \( -name "libhts${shared_ext}" -o -name "libhts${shared_ext}.*" \) | head -n1)
zstd_lib=$(find "${PREFIX}/lib" -maxdepth 1 -type f \( -name "libzstd${shared_ext}" -o -name "libzstd${shared_ext}.*" \) | head -n1)

test -n "${hts_lib}"
test -n "${zstd_lib}"

# Patch the Makefile to use conda-provided htslib and zstd headers
sed -i.bak \
    -e "s|HTS_OPTS = -I\$(HTS_DIR)/htslib/|HTS_OPTS = -I${PREFIX}/include|" \
    -e "s|ZSTD_OPTS = -I\$(ZSTD_DIR)/lib/|ZSTD_OPTS = -I${PREFIX}/include|" \
    Makefile
rm -f Makefile.bak

make onebam ONEview ONEstat seqstat seqconvert \
    CFLAGS="${CFLAGS} -I${PREFIX}/include" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib" \
    HTS_LIB="${hts_lib}" \
    ZSTD_LIB="${zstd_lib}" \
    HTS_LIBS="-L${PREFIX}/lib -lhts" \
    ZSTD_LIBS="-L${PREFIX}/lib -lzstd" \
    HTS_OBJS="" \
    ZSTD_OBJS="" \
    R_PATH="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
install -m 755 onebam ONEview ONEstat seqstat seqconvert "${PREFIX}/bin/"
