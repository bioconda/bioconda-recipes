#!/usr/bin/env bash
set -ex

cd "${SRC_DIR}"

echo "CXX is: ${CXX:-'(not set)'}"
echo "PREFIX is: ${PREFIX}"
echo "CPU_COUNT is: ${CPU_COUNT:-1}"

export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

make clean || true

make USE_CONDA=1 BUILD=release PREFIX="${PREFIX}" \
     EXTRA_CFLAGS="-I${PREFIX}/include" EXTRA_LDFLAGS="-L${PREFIX}/lib" \
     -j"${CPU_COUNT}"

# Binary'leri install et
mkdir -p "${PREFIX}/bin"

# Ana SVarp binary'si
install -m 0755 build/svarp "${PREFIX}/bin/svarp"

if [ -x third_party/wtdbg2/wtdbg2 ]; then
    install -m 0755 third_party/wtdbg2/wtdbg2 "${PREFIX}/bin/svarp-wtdbg2"
    install -m 0755 third_party/wtdbg2/wtpoa-cns "${PREFIX}/bin/svarp-wtpoa-cns"
fi

