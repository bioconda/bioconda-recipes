#!/bin/bash -ex

export CFLAGS="${CFLAGS} -O3 -Wno-cpp -Wno-unused-function -Wno-implicit-function-declaration -Wno-int-conversion"
export MACOSX_DEPLOYMENT_TARGET=10.15

# build statically linked binary with Rust
RUST_BACKTRACE=1
# Build the package using maturin - should produce *.whl files.
maturin build -m snapatac2-python/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

cd ${SRC_DIR}/snapatac2-python/ && cargo clean && rm -rf ${BUILD_PREFIX}/.cargo
