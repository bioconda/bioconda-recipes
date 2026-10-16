#!/bin/bash -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-cpp -Wno-unused-function -Wno-implicit-function-declaration -Wno-int-conversion"
export MACOSX_DEPLOYMENT_TARGET="10.15"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ `uname -s` == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET="11.0"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1
# Build the package using maturin - should produce *.whl files.
maturin build -m python/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv
