#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

OS=$(uname -s)
ARCH=$(uname -m)
# Determine features based on platform
FEATURES=""
if [[ "${OS}" == "Linux" ]]; then
    if [[ "${ARCH}" == "x86_64" ]]; then
        export FEATURES="annembed_intel-mkl,simdeez_f"
    elif [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        export FEATURES="annembed_openblas-system,stdsimd_f"
    else
        echo "Unsupported architecture '${ARCH}' on Linux."
        exit 1
    fi
elif [[ "${OS}" == "Darwin" ]]; then
    if [[ "${ARCH}" == "x86_64" || "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
        export FEATURES="annembed_openblas-system,stdsimd_f"
        export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-int-conversion"
    else
        echo "Unsupported architecture '${ARCH}' on Darwin."
        exit 1
    fi
else
    echo "Unsupported operating system '${OS}'."
    exit 1
fi

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y
export PATH="$HOME/.cargo/bin:$PATH"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --features "${FEATURES}" --verbose --no-track --locked --path . --root "${PREFIX}"
