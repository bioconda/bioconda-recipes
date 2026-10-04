#!/usr/bin/env bash
set -euo pipefail

export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export CFLAGS="${CFLAGS:-} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS:-} -O3"

export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"
export CPLUS_INCLUDE_PATH="${PREFIX}/include${CPLUS_INCLUDE_PATH:+:${CPLUS_INCLUDE_PATH}}"

# Enable portable SIMD using the recipe's existing Rust configuration.
export RUSTC_BOOTSTRAP=1
export RUST_BACKTRACE=1

echo "Target platform: ${target_platform}"
echo "Install prefix: ${PREFIX}"
rustc --version
cargo --version

case "${target_platform}" in
    linux-64)
        # NVIDIA CUDA backend with Intel MKL.
        export LD_LIBRARY_PATH="${PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

        ./install_hpc_sdk.sh </dev/null
        source ./setup_nv_compiler.sh

        cargo install \
            --features intel-mkl-static,stdsimd,cuda \
            --bin dartunifrac-cuda \
            --bin striped_unifrac-cuda \
            --locked \
            --no-track \
            --verbose \
            --path . \
            --root "${PREFIX}"
        ;;

    osx-arm64)
        # Apple Metal backend with the system Accelerate framework.
        cargo install \
            --features macos-accelerate,stdsimd,metal \
            --bin dartunifrac-metal \
            --bin striped_unifrac-metal \
            --locked \
            --no-track \
            --verbose \
            --path . \
            --root "${PREFIX}"
        ;;

    *)
        echo "Unsupported target platform: ${target_platform}" >&2
        exit 1
        ;;
esac
