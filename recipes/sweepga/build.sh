#!/bin/bash
set -xeuo pipefail

# FastGA's Makefile hardcodes CFLAGS, so conda's -isystem never reaches it.
# CPATH and LIBRARY_PATH are read by the compiler itself, whatever CFLAGS says.
export CPATH="${PREFIX}/include${CPATH:+:${CPATH}}"
export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"

# hts-sys and onecode run bindgen, which needs libclang at build time.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# onecode calls bindgen with no sysroot, so libclang would read its own glibc
# headers and disagree with the compiler about struct _IO_FILE.
if [[ $(uname) != "Darwin" ]]; then
    export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${BUILD_PREFIX}/${HOST}/sysroot -I${PREFIX}/include"
fi

if [[ $(uname) == "Darwin" ]]; then
    # FastGA's Makefile hardcodes CC = gcc, which on macOS resolves to a wrapper
    # that looks for an SDK that is not installed.
    mkdir -p "$BUILD_PREFIX/bin"
    ln -sf "$CC" "$BUILD_PREFIX/bin/gcc"
    ln -sf "$CXX" "$BUILD_PREFIX/bin/g++"
    export PATH="$BUILD_PREFIX/bin:$PATH"

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

    # For C++ builds that might not respect LDFLAGS
    export CXXFLAGS="${CXXFLAGS} -L${LIBCXX_DIR}"

    # Use gmake if available, otherwise make
    if command -v gmake >/dev/null 2>&1; then
        export MAKE="gmake"
    else
        export MAKE="make"
    fi
else
    # Linux: FastGA and WFA2-lib Makefiles call gcc and g++ by name
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

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export RUST_BACKTRACE=1
cargo install -v --locked --no-track --path . --root "${PREFIX}"

# sweepga finds these in ../libexec/sweepga, never through PATH.
LIBEXEC="${PREFIX}/libexec/sweepga"
mkdir -p "${LIBEXEC}"

# sweepga's build.rs copies the 8 tools to its cache directory.
CACHE=$(ls -d "${HOME}/.cache/sweepga/${PKG_VERSION}_"*)
for bin in wfmash FastGA FAtoGDB GIXmake GIXrm ALNtoPAF PAFtoALN ONEview; do
    install -m 755 "${CACHE}/${bin}" "${LIBEXEC}/${bin}"
done
