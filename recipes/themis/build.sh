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
# -----------------------------------------------------------------------------
# 4. 手动安装 Themis 的 Python 包（不再依赖 pip 的打包结果）
# -----------------------------------------------------------------------------
echo "[Themis] installing Themis (Python, manual copy) ..."

echo "[Themis] DEBUG: PREFIX=${PREFIX}"
echo "[Themis] DEBUG: SRC_DIR=${SRC_DIR}"
echo "[Themis] DEBUG: PYTHON=${PYTHON}"

# 一定回到源码根目录：这里应该能看到 pyproject.toml, themis/, themis_scripts/
pushd "${SRC_DIR}"
echo "[Themis] DEBUG: contents of SRC_DIR:"
ls

# 确认当前目录下确实有 themis/ 和 themis_scripts/
if [ ! -d "themis" ]; then
  echo "[Themis] ERROR: 'themis' directory not found in ${SRC_DIR}" >&2
  echo "[Themis] DEBUG: searching for themis* under SRC_DIR:" >&2
  find . -maxdepth 4 -type d -name "themis*" -print >&2 || true
  exit 1
fi

if [ ! -d "themis_scripts" ]; then
  echo "[Themis] ERROR: 'themis_scripts' directory not found in ${SRC_DIR}" >&2
  echo "[Themis] DEBUG: searching for themis_scripts under SRC_DIR:" >&2
  find . -maxdepth 4 -type d -name "themis_scripts" -print >&2 || true
  exit 1
fi

# 用 PREFIX 里的 python 计算 purelib（site-packages）路径
PY_IN_PREFIX="${PREFIX}/bin/python"
echo "[Themis] DEBUG: using python in PREFIX: ${PY_IN_PREFIX}"

SP_DIR="$("${PY_IN_PREFIX}" -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
echo "[Themis] DEBUG: purelib (site-packages) reported by PREFIX python: ${SP_DIR}"

mkdir -p "${SP_DIR}"

echo "[Themis] DEBUG: copying themis/ and themis_scripts/ into ${SP_DIR} ..."
cp -av themis themis_scripts "${SP_DIR}/"

echo "[Themis] DEBUG: after copy, find themis* under ${SP_DIR}:"
find "${SP_DIR}" -maxdepth 3 -type d -name "themis*" -print || true

popd

# 在 PREFIX/bin 下手动写一个入口脚本（覆盖 pip 生成的那个也无所谓）
cat > "${PREFIX}/bin/themis" << 'PY'
#!/usr/bin/env python
from themis.cli import main

if __name__ == "__main__":
    main()
PY
chmod +x "${PREFIX}/bin/themis"

echo "[Themis] DEBUG: listing themis* under PREFIX for sanity:"
find "${PREFIX}" -maxdepth 6 -type d -name "themis*" -print || true

# sanity check：在构建环境里用 PREFIX 的 python import 一次 themis
echo "[Themis] sanity check in build env: import themis using PREFIX python ..."
"${PY_IN_PREFIX}" - << 'PY'
import sys, sysconfig, importlib
print("[sanity] sys.prefix:", sys.prefix)
print("[sanity] purelib:", sysconfig.get_paths()["purelib"])
m = importlib.import_module("themis")
print("[sanity] themis module loaded from:", m.__file__)
PY
