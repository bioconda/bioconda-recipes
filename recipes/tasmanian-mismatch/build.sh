#!/bin/bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_LTO=false
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig:$BUILD_PREFIX/share/pkgconfig"

TARGET="${TARGET:-${HOST:-}}"
if [[ -z "$TARGET" ]]; then
  echo "ERROR: TARGET/HOST not set"
  exit 1
fi
target_env="${TARGET//[-.]/_}"

# Only set toolchain vars if they exist (avoid exporting empty strings)
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

echo "=== DEBUG ==="
ls -R target || true

CARGO_TARGET_DIR=$(find target -maxdepth 2 -type d -name release | head -n1)

echo "Using cargo target dir: $CARGO_TARGET_DIR"

for bin in tasmanian-mismatch tasmanian-diagnostics tasmanian-rescale-quality; do
  if [[ -f "$CARGO_TARGET_DIR/$bin" ]]; then
	if [[ "$(uname)" == "Linux" ]]; then
	  patchelf --set-rpath "$PREFIX/lib" "$CARGO_TARGET_DIR/$bin"
	fi
	install -Dm755 "$CARGO_TARGET_DIR/$bin" "$PREFIX/bin/$bin"
  else
	echo "ERROR: missing binary $bin in $CARGO_TARGET_DIR"
	exit 1
  fi
done
