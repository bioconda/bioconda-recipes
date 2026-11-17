#!/bin/bash
# Build SHAPEIT5 inside a conda environment.
# Apple Silicon (osx-arm64): native NEON kernels (no sse2neon).
# x86_64: AVX2/FMA kernels.
set -euo pipefail

export COMMIT_VERS="${PKG_VERSION}"
export COMMIT_DATE="$(date -Idate -u)"

OS=$(uname -s)
ARCH=$(uname -m)

# htslib static lib: prefer the conda env, fall back to Homebrew (local dev builds).
if [[ -f "${PREFIX}/lib/libhts.a" ]]; then
    HTSSRC="${PREFIX}"
elif command -v brew >/dev/null 2>&1; then
    HTSSRC="$(brew --prefix)"
else
    HTSSRC="${PREFIX}"
fi

if [[ "${OS}" == "Darwin" && ("${ARCH}" == "arm64" || "${ARCH}" == "aarch64") ]]; then
    # Apple Silicon: NEON code path selected by __ARM_NEON (default on arm64).
    # No -march flag: the conda clang_osx-arm64 toolchain may be an x86_64
    # cross-compiler (Rosetta), where -march=native resolves to x86 targets.
    # Base arm64 is NEON-capable and covers every instruction the kernels use.
    EXTRA_ARCH_FLAGS=""
elif [[ "${ARCH}" == "aarch64" || "${ARCH}" == "arm64" ]]; then
    # Linux aarch64: base arm64 (NEON), no AVX2.
    EXTRA_ARCH_FLAGS=""
else
    EXTRA_ARCH_FLAGS="-mavx2 -mfma"
fi

# Drop any -march=... inherited from the conda toolchain (e.g. -march=westmere
# when cross-compiling from an osx-64 build platform): it is x86-only and
# conflicts with the explicit arch flags below.
CLEAN_CXXFLAGS="$(printf '%s\n' "${CXXFLAGS}" | tr ' ' '\n' | grep -v '^-march=' | tr '\n' ' ')"
CXXFLAGS="${CLEAN_CXXFLAGS} -O3 ${EXTRA_ARCH_FLAGS} -Wno-unused-command-line-argument -Wno-ignored-attributes"
CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
if [[ "${OS}" == "Darwin" ]]; then
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -fno-define-target-os-macros"
else
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
fi

DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate -lm -lcrypto"
DYN_LIBS="${DYN_LIBS} -lboost_iostreams -lboost_program_options -lboost_serialization"

# The makefile link rule receives the boost archives as file paths.
# conda-forge ships boost as shared libraries on macOS (.dylib), so fall
# back to the shared library when no static archive is available.
boost_lib() {
    if [[ -f "${PREFIX}/lib/lib${1}.a" ]]; then
        echo "${PREFIX}/lib/lib${1}.a"
    elif [[ -f "${PREFIX}/lib/lib${1}.so" ]]; then
        echo "${PREFIX}/lib/lib${1}.so"
    else
        echo "${PREFIX}/lib/lib${1}.dylib"
    fi
}
BOOST_IO="$(boost_lib boost_iostreams)"
BOOST_PO="$(boost_lib boost_program_options)"
BOOST_SE="$(boost_lib boost_serialization)"

for subdir in phase_common phase_rare switch ligate simulate xcftools; do
    pushd "${subdir}"
    make \
        -j"${CPU_COUNT}" \
        CXX="${CXX} -std=c++20" \
        CXXFLAG="${CXXFLAGS} -D__COMMIT_ID__='\"${COMMIT_VERS}\"' -D__COMMIT_DATE__='\"${COMMIT_DATE}\"'" \
        LDFLAG="${LDFLAGS}" \
        DYN_LIBS="${DYN_LIBS}" \
        HTSLIB_INC="${HTSSRC}/include" \
        HTSLIB_LIB="${HTSSRC}/lib/libhts.a" \
        BOOST_INC="${PREFIX}/include" \
        BOOST_LIB_IO="${BOOST_IO}" \
        BOOST_LIB_PO="${BOOST_PO}" \
        BOOST_LIB_SE="${BOOST_SE}"
    install -v -m 0755 "bin/${subdir}" "${PREFIX}/bin/SHAPEIT5_${subdir}"
    popd
done

# Strip for a smaller package
if command -v strip >/dev/null 2>&1; then
    for b in "${PREFIX}"/bin/SHAPEIT5_*; do
        if [[ "${OS}" == "Darwin" ]]; then
            strip -S "${b}" || true
        else
            strip --strip-unneeded "${b}" || true
        fi
    done
fi
