#!/usr/bin/env bash
set -euxo pipefail

# Conda-build automatically sets CPU_COUNT, use it for Cargo
export CARGO_BUILD_JOBS=${CPU_COUNT:-1}

# OpenBLAS paths provided by the conda environment
export JANUSX_REQUIRE_OPENBLAS=1
export OPENBLAS_LIB_DIR="${PREFIX}/lib"
export OPENBLAS_INCLUDE_DIR="${PREFIX}/include"

wheel_dir="${PWD}/dist-conda-wheel"
mkdir -p "${wheel_dir}"

# Build the wheel directly with maturin
"${PYTHON}" -m maturin build \
  --release \
  --interpreter "${PYTHON}" \
  --compatibility off \
  --out "${wheel_dir}" \
  -v

# Install the wheel
"${PYTHON}" -m pip install "${wheel_dir}"/janusx-*.whl \
  --no-deps \
  -vv

# Strict post-build backend gate
"${PYTHON}" -c "import janusx.janusx as _jx; assert str(_jx.rust_sgemm_backend()) == 'openblas'"

# Collect Rust dependency licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml