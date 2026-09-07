#!/bin/bash
set -euxo pipefail

export TRIDENT_SKIP_CONDA_TOOLS=1

make -C trident/tools/build_data clean
make -C trident/tools/build_data -j "${CPU_COUNT}" all \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} -O3 -std=c++17 -pthread -I${PREFIX}/include" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -pthread -lz"

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

test -x "${SP_DIR}/trident/tools/build_data/coverage"
test -x "${SP_DIR}/trident/tools/build_data/build_counts"

cp "${RECIPE_DIR}/LICENSE.kraken2" "${SRC_DIR}/LICENSE.kraken2"
