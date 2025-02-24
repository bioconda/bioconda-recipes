#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# Identify OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

# Determine features based on platform
FEATURES=""
if [[ "${OS}" == "Darwin" ]]; then
    # macOS
    # Both x86_64 and arm64 (Apple Silicon) will use the same features
    # If you need to differentiate, uncomment the lines below
    # if [[ "${ARCH}" == "x86_64" ]]; then
    #     FEATURES="stdsimd,macos-accelerate"
    # elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
    #     FEATURES="stdsimd,macos-accelerate"
    # fi
    FEATURES="stdsimd"
else
    # Linux
    if [[ "${ARCH}" == "x86_64" ]]; then
        FEATURES="intel-mkl-static,simdeez_f"
    elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        FEATURES="openblas-system,stdsimd"
    else
        echo "Unsupported architecture '${ARCH}' on Linux."
        exit 1
    fi
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
export RUSTC_BOOTSTRAP=1
RUST_BACKTRACE=1
cargo install --path . --root "${PREFIX}" \
    --features "${FEATURES}" \
    --no-track
