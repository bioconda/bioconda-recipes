#!/bin/bash
set -euo pipefail
make -f build.mk HTSLIB_PREFIX="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS} -O2 ${LDFLAGS}"
mkdir -p "${PREFIX}/bin"
install -m 755 dms_count "${PREFIX}/bin/dms_count"
