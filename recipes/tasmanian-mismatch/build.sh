#!/bin/bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_LTO=false
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig:$BUILD_PREFIX/share/pkgconfig"

TARGET="${TARGET:-${HOST:-}}"
if [[ -z "$TARGET" ]]; then
    echo "ERROR: TARGET/HOST not set"
    exit 1
fi

echo "TARGET=$TARGET"
echo "HOST=${HOST:-<unset>}"

target_env="${TARGET//[-.]/_}"

# Only set toolchain vars if they exist
if [[ -n "${CC:-}" ]]; then
    export "CC_${target_env}=${CC}"
fi
if [[ -n "${CXX:-}" ]]; then
    export "CXX_${target_env}=${CXX}"
fi
if [[ -n "${AR:-}" ]]; then
    export "AR_${target_env}=${AR}"
fi
if [[ -n "${RANLIB:-}" ]]; then
    export "RANLIB_${target_env}=${RANLIB}"
fi

if [[ -n "${CFLAGS:-}" ]]; then
    export "CFLAGS_${target_env}=${CFLAGS}"
fi
if [[ -n "${CXXFLAGS:-}" ]]; then
    export "CXXFLAGS_${target_env}=${CXXFLAGS}"
fi
if [[ -n "${LDFLAGS:-}" ]]; then
    export "LDFLAGS_${target_env}=${LDFLAGS}"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo build --release --locked -vv 2>&1 | tee build.log

echo "=== DEBUG: RELEASE DIRS ==="
find target -type d -name release | sort || true

echo "=== DEBUG: TASMANIAN FILES ==="
find target -name 'tasmanian*' | sort || true

echo "=== DEBUG: EXECUTABLES ==="
find target -type f -executable | sort || true

# Find the directory that actually contains the main binary
CARGO_TARGET_DIR=""

for candidate in \
    "target/release" \
    "target/${TARGET}/release"
do
    if [[ -x "${candidate}/tasmanian-mismatch" ]]; then
        CARGO_TARGET_DIR="${candidate}"
        break
    fi
done

# Fallback: search anywhere under target
if [[ -z "${CARGO_TARGET_DIR}" ]]; then
    main_bin=$(find target -type f -name 'tasmanian-mismatch' | head -n1 || true)
    if [[ -n "${main_bin}" ]]; then
        CARGO_TARGET_DIR="$(dirname "${main_bin}")"
    fi
fi

if [[ -z "${CARGO_TARGET_DIR}" ]]; then
    echo "ERROR: could not locate tasmanian-mismatch binary"
    exit 1
fi

echo "Using cargo target dir: ${CARGO_TARGET_DIR}"

for bin in \
    tasmanian-mismatch \
    tasmanian-diagnostics \
    tasmanian-rescale-quality
do
    if [[ -f "${CARGO_TARGET_DIR}/${bin}" ]]; then
        if [[ "$(uname)" == "Linux" ]]; then
            patchelf --set-rpath "$PREFIX/lib" "${CARGO_TARGET_DIR}/${bin}"
        fi

        install -Dm755 \
            "${CARGO_TARGET_DIR}/${bin}" \
            "$PREFIX/bin/${bin}"
    else
        echo "ERROR: missing binary ${bin} in ${CARGO_TARGET_DIR}"
        exit 1
    fi
done

echo "Installed binaries:"
ls -l "$PREFIX/bin"/tasmanian*

