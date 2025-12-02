#!/usr/bin/env bash
set -ex

cd "${SRC_DIR}"

echo "CXX is: ${CXX:-'(not set)'}"
echo "PREFIX is: ${PREFIX}"
echo "CPU_COUNT is: ${CPU_COUNT:-1}"

make clean || true

make USE_CONDA=1 BUILD=release PREFIX="${PREFIX}" -j"${CPU_COUNT}"

# Binary'leri install et
mkdir -p "${PREFIX}/bin"

# Ana SVarp binary'si
install -m 0755 build/svarp "${PREFIX}/bin/svarp"

if [ -x dep/wtdbg2/wtdbg2 ]; then
    install -m 0755 dep/wtdbg2/wtdbg2 "${PREFIX}/bin/svarp-wtdbg2"
fi

