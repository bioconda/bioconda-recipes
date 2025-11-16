#!/usr/bin/env bash
set -euo pipefail
echo "[Themis] unified build started"

export CMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL:-${CPU_COUNT:-1}}
export RUST_BACKTRACE=1


export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
echo "[Themis] building ganon (C++) ..."
pushd "${SRC_DIR}/thirdparty/ganon_mod"
rm -rf build_cpp
cmake -S . -B build_cpp -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCONDA=ON \
  -DVERBOSE_CONFIG=ON
cmake --build build_cpp --parallel "${CMAKE_BUILD_PARALLEL_LEVEL}"
cmake --install build_cpp
popd


file "${PREFIX}/bin/ganon-classify"
file "${PREFIX}/bin/ganon-build"

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
echo "[Themis] installing ganon (Python) ..."
pushd "${SRC_DIR}/thirdparty/ganon_mod"

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
popd


cat > "${PREFIX}/bin/ganon-report" <<'SH'
#!/usr/bin/env bash
exec "${CONDA_PREFIX}/bin/python" -m ganon.report "$@"
SH
chmod +x "${PREFIX}/bin/ganon-report"

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
echo "[Themis] building ggcat (Rust) ..."
pushd "${SRC_DIR}/thirdparty/ggcat_mod"

cargo install --locked --root "${PREFIX}" --path crates/cmdline/

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml" || true
popd

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
echo "[Themis] installing Themis (Python) ..."
pushd "${SRC_DIR}"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
popd

# sanity check：import themis
"${PREFIX}/bin/python" - <<'PY'
import importlib, sys
m = importlib.import_module("themis")
print("[sanity] themis module:", m.__file__)
PY

echo "[Themis] unified build finished"
