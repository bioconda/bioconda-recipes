#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

echo "=== PREFIX ==="
env |grep PREFIX

echo "Arch: $(uname -s)"

./install_hpc_sdk.sh </dev/null
source ./setup_nv_compiler.sh


# build binary with Rust
export RUSTC_BOOTSTRAP=1
# build binary with Rust
RUST_BACKTRACE=1 cargo install --features intel-mkl-static,stdsimd,cuda --locked --no-track -v --path . --root "$PREFIX"

