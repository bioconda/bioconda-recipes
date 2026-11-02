#!/usr/bin/env bash
set -euo pipefail
set -x

export CPATH="${PREFIX}/include:${CPATH:-}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH:-}"

for d in lib/pgenlib lib/faddeeva lib/qfc; do
  make -C "${d}" clean
  make -C "${d}" \
    CXX="${CXX}" \
    AR="${AR:-ar}" \
    CXXFLAGS="${CXXFLAGS:-} -O3 -Wall -std=c++11"
done

mkdir -p build

cmake -S "${SRC_DIR}" -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="${CC}" \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DEIGEN_PATH="${PREFIX}/include/eigen3" \
  -DHTSLIB_PATH="${PREFIX}" \
  -DBOOST_PATH="${PREFIX}"

cmake --build build --target remeta -- -j"${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
install -m 755 build/remeta "${PREFIX}/bin/remeta"
