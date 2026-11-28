#!/bin/bash
set -euo pipefail
make -f build.mk ISAL_PREFIX="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS} -O3" LDFLAGS="${LDFLAGS}"
mkdir -p "${PREFIX}/bin"
install -m 755 dms_data_lint "${PREFIX}/bin/dms_data_lint"
