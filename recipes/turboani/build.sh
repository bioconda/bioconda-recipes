#!/bin/bash
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export CFLAGS="${CFLAGS:-} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS:-} -O3"

OS="$(uname -s)"
ARCH="$(uname -m)"
export OS ARCH

case "${OS}-${ARCH}" in
    Linux-x86_64)
        RUST_CPU_TARGET="x86-64-v3"
        ;;
    Linux-aarch64|Linux-arm64|Darwin-x86_64|Darwin-arm64|Darwin-aarch64)
        RUST_CPU_TARGET="native"
        ;;
    *)
        echo "Unsupported platform: ${OS}-${ARCH}" >&2
        exit 1
        ;;
esac

export RUSTC_BOOTSTRAP=1
export RUSTFLAGS="${RUSTFLAGS:-} -C target-cpu=${RUST_CPU_TARGET}"

echo "Building turboani for ${OS}-${ARCH} with target-cpu=${RUST_CPU_TARGET}"

cargo install \
    --features visual \
    --locked \
    --no-track \
    --verbose \
    --path . \
    --root "${PREFIX}"

"${STRIP}" "${PREFIX}/bin/turboani"
"${STRIP}" "${PREFIX}/bin/fastani"
