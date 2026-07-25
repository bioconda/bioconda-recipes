#!/bin/bash -euo
set -xe

# FastGA's Makefile hardcodes CFLAGS, so conda's -isystem never reaches it.
# CPATH and LIBRARY_PATH are read by the compiler itself, whatever CFLAGS says.
export CPATH="${PREFIX}/include${CPATH:+:${CPATH}}"
export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"

# rust-htslib runs bindgen, which needs libclang at build time.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

if [[ $(uname) == "Darwin" ]]; then
    # Set PLATFORM for ARM64 Macs as AGC expects
    if [[ $(uname -m) == "arm64" ]]; then
        export PLATFORM=arm8
    fi

    # Use the conda-provided Clang compilers
    echo "Using CC: $CC"
    echo "Using CXX: $CXX"
    $CC --version || true
    $CXX --version || true

    # Find the C++ standard library location
    LIBCXX_DIR="$BUILD_PREFIX/lib"
    if [[ ! -f "$LIBCXX_DIR/libc++.dylib" ]] && [[ ! -f "$LIBCXX_DIR/libc++.a" ]]; then
        # Try to find libc++ in the conda environment
        LIBCXX_DIR="$PREFIX/lib"
    fi

    # Set up Rust to use clang++ as the linker and link with libc++
    export RUSTFLAGS="-C linker=${CXX} -C link-arg=-L${LIBCXX_DIR} -C link-arg=-lc++ -C link-arg=-Wl,-rpath,${PREFIX}/lib"

    # Ensure C++ builds within cargo use the same settings
    export CMAKE_CXX_FLAGS="${CXXFLAGS}"
    export CMAKE_C_FLAGS="${CFLAGS}"
    export CMAKE_CXX_COMPILER="${CXX}"
    export CMAKE_C_COMPILER="${CC}"
    export CMAKE_PREFIX_PATH="${PREFIX}"

    # For builds that use pkg-config
    export PKG_CONFIG_ALLOW_CROSS=1

    # Ensure the C++ standard library is available
    export LDFLAGS="${LDFLAGS} -L${LIBCXX_DIR} -lc++"
    export LIBRARY_PATH="${LIBCXX_DIR}:${LIBRARY_PATH:-}"

    # IMPORTANT: Set DYLD_FALLBACK_LIBRARY_PATH to help cmake find its libraries
    # This is safer than DYLD_LIBRARY_PATH as it only gets used if libraries aren't found normally
    export DYLD_FALLBACK_LIBRARY_PATH="${BUILD_PREFIX}/lib:${PREFIX}/lib:/usr/lib:/System/Library/Frameworks"

    # For C++ builds that might not respect LDFLAGS
    export CXXFLAGS="${CXXFLAGS} -L${LIBCXX_DIR}"

    # Use gmake if available, otherwise make
    if command -v gmake >/dev/null 2>&1; then
        export MAKE="gmake"
    else
        export MAKE="make"
    fi
else
    # Linux: Create symlinks for standard compiler names that AGC makefile expects
    mkdir -p "$BUILD_PREFIX/bin"
    ln -sf $CC "$BUILD_PREFIX/bin/gcc"
    ln -sf $CXX "$BUILD_PREFIX/bin/g++"

    # Ensure the symlinks are in PATH
    export PATH="$BUILD_PREFIX/bin:$PATH"

    # Also export the standard names
    export CC="$BUILD_PREFIX/bin/gcc"
    export CXX="$BUILD_PREFIX/bin/g++"
fi

# Do not use -march=native, the package must run on any host
export PORTABLE=1

# Debug: Print final compiler information
echo "Final CC: $CC"
echo "Final CXX: $CXX"
echo "Final CXXFLAGS: $CXXFLAGS"
echo "Final LDFLAGS: $LDFLAGS"
echo "Final RUSTFLAGS: ${RUSTFLAGS:-}"
echo "Final CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS:-}"
echo "Final LIBRARY_PATH: ${LIBRARY_PATH:-}"
echo "Final DYLD_FALLBACK_LIBRARY_PATH: ${DYLD_FALLBACK_LIBRARY_PATH:-}"
$CC --version || true
$CXX --version || true

# Only verify GCC on Linux where AGC support is enabled
if [[ $(uname) != "Darwin" ]]; then
    # Verify we have real GCC (check for either "GNU" or "gcc" in the output)
    if ! $CC --version 2>&1 | grep -qE "(GNU|gcc)"; then
        echo "ERROR: CC is not GNU GCC!"
        exit 1
    fi
fi

# Run cargo-bundle-licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# cargo install alone uses a temp target dir and deletes the companion binaries.
export CARGO_TARGET_DIR="${SRC_DIR}/target"

export RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

# impg finds these next to itself or in ../libexec/impg, never through PATH.
LIBEXEC="${PREFIX}/libexec/impg"
mkdir -p "${LIBEXEC}"
mv "${PREFIX}/bin/gfaffix" "${LIBEXEC}/gfaffix"

BUILT="${CARGO_TARGET_DIR}/release"

# The build tree is the reliable source once cargo has returned.
find_built() {
    local name="$1" hit
    if [[ -f "${BUILT}/${name}" ]]; then
        echo "${BUILT}/${name}"
        return 0
    fi
    hit=$(find "${BUILT}/build" -maxdepth 4 -type f -name "${name}" -print -quit 2>/dev/null || true)
    [[ -n "${hit}" ]] && echo "${hit}"
}

for bin in wfmash FastGA FAtoGDB GIXmake GIXrm ALNtoPAF PAFtoALN ONEview; do
    src=$(find_built "${bin}" || true)
    if [[ -z "${src}" ]]; then
        echo "ERROR: companion binary ${bin} was not built"
        exit 1
    fi
    echo "installing companion binary ${bin} from ${src}"
    install -m 755 "${src}" "${LIBEXEC}/${bin}"
done

# wfmash's build-time RPATH points into the target dir, which does not survive.
mkdir -p "${PREFIX}/lib"
found_libs=0
while IFS= read -r lib; do
    echo "installing runtime library $(basename "${lib}")"
    install -m 755 "${lib}" "${PREFIX}/lib/"
    found_libs=$((found_libs + 1))
done < <(find "${BUILT}" -name 'libwfa2*.so*' -o -name 'libwfa2*.dylib' | sort -u)
if [[ "${found_libs}" -eq 0 ]]; then
    echo "ERROR: no libwfa2 runtime libraries found"
    exit 1
fi

test -x "${PREFIX}/bin/impg" || { echo "ERROR: impg was not installed"; exit 1; }
for bin in gfaffix wfmash FastGA FAtoGDB GIXmake GIXrm ALNtoPAF PAFtoALN ONEview; do
    test -x "${LIBEXEC}/${bin}" || { echo "ERROR: ${bin} was not installed"; exit 1; }
done
# bin/ must stay clean, or we clobber the wfmash, gfaffix and fastga packages.
for bin in gfaffix wfmash FastGA FAtoGDB GIXmake GIXrm ALNtoPAF PAFtoALN ONEview; do
    if [[ -e "${PREFIX}/bin/${bin}" ]]; then
        echo "ERROR: ${bin} leaked into bin/"
        exit 1
    fi
done
echo "installed impg in bin/ and 9 companions in libexec/impg/"
