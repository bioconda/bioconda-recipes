#!/bin/bash -ex

# Use a custom temporary directory as home on macOS.
# (not sure why this is useful, but people use it in bioconda recipes)
if [ `uname` == Darwin ]; then
	export HOME=`mktemp -d`
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1
# Build the package using maturin - should produce *.whl files.
maturin build -m snapatac2-python/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install *.whl files using pip
${PYTHON} -m pip install snapatac2-python/target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

cd ${SRC_DIR}/snapatac2-python/ && cargo clean && rm -rf ${BUILD_PREFIX}/.cargo
