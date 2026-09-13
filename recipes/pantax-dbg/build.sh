#!/usr/bin/env bash
set -euo pipefail

echo "[PanTax-DBG] unified build started"

export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-${CPU_COUNT:-1}}"
export RUST_BACKTRACE=1
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

LIBEXEC_DIR="${PREFIX}/libexec/pantax-dbg"
mkdir -p "${LIBEXEC_DIR}"

echo "[PanTax-DBG] building DBG-ganon (C++ backend) ..."
pushd "${SRC_DIR}/thirdparty/dbg_ganon"

rm -rf build_cpp
cmake -S . -B build_cpp -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCONDA=ON \
  -DVERBOSE_CONFIG=ON

cmake --build build_cpp --parallel "${CMAKE_BUILD_PARALLEL_LEVEL}"
cmake --install build_cpp
popd

echo "[PanTax-DBG] installing DBG-ganon Python frontend ..."
pushd "${SRC_DIR}/thirdparty/dbg_ganon"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
popd

for exe in ganon ganon-build ganon-classify; do
  if [[ -x "${PREFIX}/bin/${exe}" ]]; then
    install -m 755 "${PREFIX}/bin/${exe}" "${LIBEXEC_DIR}/${exe}"
    rm -f "${PREFIX}/bin/${exe}"
  else
    echo "ERROR: expected ${PREFIX}/bin/${exe} was not created"
    find "${PREFIX}/bin" -maxdepth 1 -type f -perm -111 -print || true
    exit 1
  fi
done

cat > "${LIBEXEC_DIR}/ganon-report" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
exec "${PREFIX_DIR}/bin/python" -m ganon.report "$@"
SH
chmod +x "${LIBEXEC_DIR}/ganon-report"

echo "[PanTax-DBG] building DBG-ggcat (Rust backend) ..."
pushd "${SRC_DIR}/thirdparty/dbg_ggcat"

cargo install --locked --root "${PREFIX}" --path crates/cmdline/

if [[ -x "${PREFIX}/bin/ggcat" ]]; then
  install -m 755 "${PREFIX}/bin/ggcat" "${LIBEXEC_DIR}/dbg-ggcat"
  rm -f "${PREFIX}/bin/ggcat"
elif [[ -x "${PREFIX}/bin/dbg-ggcat" ]]; then
  install -m 755 "${PREFIX}/bin/dbg-ggcat" "${LIBEXEC_DIR}/dbg-ggcat"
  rm -f "${PREFIX}/bin/dbg-ggcat"
else
  echo "ERROR: cannot find installed ggcat binary under ${PREFIX}/bin"
  find "${PREFIX}/bin" -maxdepth 1 -type f -perm -111 -print || true
  exit 1
fi

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml" || true
popd

echo "[PanTax-DBG] installing PanTax-DBG Python package ..."
pushd "${SRC_DIR}"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
popd

"${PREFIX}/bin/python" - <<'PY'
import importlib
for mod in ["pantax_dbg", "pantax_dbg_scripts"]:
    m = importlib.import_module(mod)
    print(f"[sanity] imported {mod}: {m.__file__}")
PY

test -x "${LIBEXEC_DIR}/ganon"
test -x "${LIBEXEC_DIR}/ganon-build"
test -x "${LIBEXEC_DIR}/ganon-classify"
test -x "${LIBEXEC_DIR}/ganon-report"
test -x "${LIBEXEC_DIR}/dbg-ggcat"

echo "[PanTax-DBG] internal backends:"
ls -lh "${LIBEXEC_DIR}"

echo "[PanTax-DBG] unified build finished"
