#!/usr/bin/env bash

set -euo pipefail

build_one() {
    local name="$1"
    local simd_target="$2"
    local extra_arch_flags="${3:-}"
    local build_dir="${SRC_DIR}/build-${name}"
    local extra_cmake_args=()

    if [[ -n "${extra_arch_flags}" ]]; then
        extra_cmake_args+=(
            "-DCMAKE_C_FLAGS=${CFLAGS:-} ${extra_arch_flags}"
            "-DCMAKE_CXX_FLAGS=${CXXFLAGS:-} ${extra_arch_flags}"
        )
    fi

    cmake ${CMAKE_ARGS:-} \
        -S "${SRC_DIR}" \
        -B "${build_dir}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DANCHORWAVE_SIMD_TARGET="${simd_target}" \
        -DANCHORWAVE_ENABLE_WFA_PARALLEL=ON \
        "${extra_cmake_args[@]}"
    cmake --build "${build_dir}" --target install -- -j "${CPU_COUNT}"
}

platform="${target_platform:-}"
if [[ -z "${platform}" ]]; then
    case "$(uname -s)-$(uname -m)" in
        Linux-x86_64) platform="linux-64" ;;
        Linux-aarch64|Linux-arm64) platform="linux-aarch64" ;;
        Darwin-x86_64) platform="osx-64" ;;
        Darwin-arm64) platform="osx-arm64" ;;
        *) platform="unsupported" ;;
    esac
fi

case "${platform}" in
linux-64)
    build_one sse2 sse2
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse2"

    build_one sse4.1 sse4
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_sse4.1"

    build_one avx2 avx2
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx2"

    # The project exposes explicit portable targets through CMake. AVX-512 is
    # intentionally delegated to toolchain flags so the same source remains
    # usable for cross builds.
    build_one avx512 toolchain -march=skylake-avx512
    mv "${PREFIX}/bin/anchorwave" "${PREFIX}/bin/anchorwave_avx512"

    install -m 0755 "${RECIPE_DIR}/anchorwave" "${PREFIX}/bin/anchorwave"
    ;;

osx-64)
    build_one sse4.1 sse4
    ;;

linux-aarch64|osx-arm64)
    build_one arm64 toolchain
    ;;

*)
    echo "unsupported target platform: ${platform}" >&2
    exit 1
    ;;
esac
