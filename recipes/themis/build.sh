#!/usr/bin/env bash
set -euo pipefail
echo "[Themis] unified build started"

export CMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL:-${CPU_COUNT:-1}}
export RUST_BACKTRACE=1

export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

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

# 

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
echo "[Themis] building ggcat (Rust) ..."
pushd "${SRC_DIR}/thirdparty/ggcat_mod"
cargo install --locked --root "${PREFIX}" --path crates/cmdline/
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml" || true
popd

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
echo "[Themis] installing Themis (Python, manual copy) ..."

# 一定回到源码根目录：这里应该能看到 pyproject.toml, themis/, themis_scripts/
pushd "${SRC_DIR}"
echo "[Themis] SRC_DIR contents:"
ls

# 用 conda 提供的 PYTHON（推荐用 $PYTHON，而不是手写 PREFIX/bin/python）
SP_DIR="$(${PYTHON} -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
echo "[Themis] purelib (site-packages) resolved by \$PYTHON = ${SP_DIR}"

mkdir -p "${SP_DIR}"
echo "[Themis] copying themis packages into ${SP_DIR} ..."
cp -a themis themis_scripts "${SP_DIR}/"

echo "[Themis] after copy, listing themis* under ${SP_DIR}:"
find "${SP_DIR}" -maxdepth 2 -type d -name "themis*" -print || true

popd

# 在 PREFIX/bin 下手动写一个入口脚本
cat > "${PREFIX}/bin/themis" << 'PY'
#!/usr/bin/env python
from themis.cli import main

if __name__ == "__main__":
    main()
PY
chmod +x "${PREFIX}/bin/themis"

echo "[Themis] listing potential themis locations under PREFIX for debugging:"
find "${PREFIX}" -maxdepth 6 -type d -name "themis*" -print || true

# sanity check：用 $PYTHON（conda 指向 host python）来 import themis
echo "[Themis] sanity check in build env: import themis using \$PYTHON ..."
${PYTHON} - << 'PY'
import importlib
m = importlib.import_module("themis")
print("[sanity] themis module loaded from:", m.__file__)
PY
