#!/bin/bash -euo

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"
OS=$(uname -s)
ARCH=$(uname -m)
# Determine features based on platform
FEATURES=""
if [[ "${OS}" == "Linux" ]]; then
    if [[ "${ARCH}" == "x86_64" ]]; then
        FEATURES="annembed_intel-mkl,simdeez_f"
    elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        FEATURES="annembed_openblas-system,stdsimd_f"
    else
        echo "Unsupported architecture '${ARCH}' on Linux."
        exit 1
    fi
elif [[ "${OS}" == "Darwin" ]]; then
    if [[ "${ARCH}" == "x86_64" || "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        FEATURES="annembed_openblas-system,stdsimd_f"
    else
        echo "Unsupported architecture '${ARCH}' on Darwin."
        exit 1
    fi
else
    echo "Unsupported operating system '${OS}'."
    exit 1
fi

# build statically linked binary with Rust
export RUSTC_BOOTSTRAP=1
RUST_BACKTRACE=1 cargo install --features "${FEATURES}" --verbose --path . --root $PREFIX
RUST_BACKTRACE=1 cargo install --verbose --path ./binaux --root $PREFIX --force
