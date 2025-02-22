#!/bin/bash -euo

# Workaround for SSH-based Git connections from Rust/cargo
# We set CARGO_HOME because conda-build doesn't pass HOME
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_HOME="$(pwd)/.cargo"

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
    FEATURES="stdsimd,macos-accelerate"
else
    # Linux
    if [[ "${ARCH}" == "x86_64" ]]; then
        FEATURES="intel-mkl-static,simdeez_f"
    elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        FEATURES="openblas-static,stdsimd"
    else
        echo "Unsupported architecture '${ARCH}' on Linux."
        exit 1
    fi
fi

# Build statically linked binary with Rust
RUST_BACKTRACE=1 \
cargo install \
  --path . \
  --features "${FEATURES}" \
  --root $PREFIX
