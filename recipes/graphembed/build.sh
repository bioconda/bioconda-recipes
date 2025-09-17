#!/bin/bash -euo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# Identify OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

# Determine features based on platform
FEATURES=""
if [[ "${OS}" == "Linux" ]]; then
    if [[ "${ARCH}" == "x86_64" ]]; then
        FEATURES="intel-mkl-static,simdeez_f"
    elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        FEATURES="openblas-system,stdsimd"
    else 
        echo "Unsupported architecture '${ARCH}' on Linux."
        exit 1
    fi
elif [[ "${OS}" == "Darwin" ]]; then
    if [[ "${ARCH}" == "x86_64" || "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        FEATURES="openblas-system,stdsimd"
    else
        echo "Unsupported architecture '${ARCH}' on Darwin."
        exit 1
    fi
else
    echo "Unsupported operating system '${OS}'."
    exit 1
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
export RUSTC_BOOTSTRAP=1
RUST_BACKTRACE=1
cargo install --path . --root "${PREFIX}" \
    --features "${FEATURES}" \
    --no-track
