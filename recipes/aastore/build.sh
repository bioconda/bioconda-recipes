#!/usr/bin/env bash
set -euo pipefail

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-1}"
export CMAKE_GENERATOR=Ninja

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation \
    -Cbuild-dir=build-conda \
    -Ccmake.define.AASTORE_ENABLE_IO_URING=ON \
    -Ccmake.define.AAStoreUring_INCLUDE_DIR="${PREFIX}/include" \
    -Ccmake.define.AAStoreUring_LIBRARY="${PREFIX}/lib/liburing.so" \
    -Ccmake.define.AASTORE_ENABLE_IPO=OFF

# Upstream permits a pread-only build when liburing cannot be used. Require
# the conda package's liburing backend to compile; runtime availability varies.
"${PYTHON}" - <<'PY'
from pathlib import Path

cache = Path("build-conda/CMakeCache.txt").read_text()
assert "AAStoreUring_HAS_BASELINE:INTERNAL=1" in cache, "liburing capability check failed"
assert "AASTORE_HAVE_IO_URING=1" in Path("build-conda/build.ninja").read_text(), \
    "io_uring backend was not compiled"
PY
