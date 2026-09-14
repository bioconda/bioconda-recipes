#!/bin/bash -euo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
  export CFLAGS="${CFLAGS} -Wno-int-conversion -Wno-implicit-function-declaration"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build with maturin for the monorepo structure
RUST_BACKTRACE=1
maturin build -m lightmotif-py/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install the wheel file
${PYTHON} -m pip install lightmotif-py/target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv