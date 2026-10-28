#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"

export OS=$(uname -s)
export ARCH=$(uname -m)
# Determine features based on platform
FEATURES=""

if [[ "${OS}" == "Linux" ]]; then
    if [[ "${ARCH}" == "x86_64" ]]; then
        export FEATURES="intel-mkl-static,stdsimd"
    elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        export FEATURES="openblas-system,stdsimd"
    else
        echo "Unsupported architecture '${ARCH}' on Linux."
        exit 1
    fi
elif [[ "${OS}" == "Darwin" ]]; then
    if [[ "${ARCH}" == "x86_64" || "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        export FEATURES="openblas-system,stdsimd"
    else
        echo "Unsupported architecture '${ARCH}' on Darwin."
        exit 1
    fi
else
    echo "Unsupported operating system '${OS}'."
    exit 1
fi

# build binary with Rust
export RUSTC_BOOTSTRAP=1
# build binary with Rust
RUST_BACKTRACE=1 cargo install --features "${FEATURES}" --locked --no-track -v --path . --root "$PREFIX"

"${STRIP}" "$PREFIX/bin/dartunifrac"
