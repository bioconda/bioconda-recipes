set -euo pipefail
set -x

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-1}"
export MAKEFLAGS="-j${CPU_COUNT:-1}"

export CMAKE_PREFIX_PATH="${PREFIX}:${CMAKE_PREFIX_PATH:-}"
export CMAKE_INCLUDE_PATH="${PREFIX}/include:${CMAKE_INCLUDE_PATH:-}"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib:${CMAKE_LIBRARY_PATH:-}"

rm -rf build
mkdir -p build
cd build

if [[ "${target_platform:-}" == osx-* ]]; then
  cat > ranlib-wrapper.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REAL="${REAL_RANLIB:-${RANLIB:-ranlib}}"
tmp="$(mktemp)"

set +e
"$REAL" -no_warning_for_no_symbols "$@" 2> "$tmp"
rc=$?
set -e

if [ $rc -ne 0 ] && grep -qiE 'unknown|unrecognized|illegal option' "$tmp"; then
  : > "$tmp"
  set +e
  "$REAL" "$@" 2> "$tmp"
  rc=$?
  set -e
fi

if [ $rc -ne 0 ]; then
  if grep -q 'has no symbols' "$tmp" && ! grep -qv 'has no symbols' "$tmp"; then
    rc=0
  fi
fi

cat "$tmp" >&2 || true
rm -f "$tmp"
exit $rc
EOF

  chmod +x ranlib-wrapper.sh

  export REAL_RANLIB="${RANLIB:-ranlib}"
  export RANLIB="${PWD}/ranlib-wrapper.sh"
  CMAKE_RANLIB_ARG="-DCMAKE_RANLIB=${RANLIB}"
else
  CMAKE_RANLIB_ARG=""
fi

cmake .. \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSB_ENABLE_LTO=OFF \
  -DSB_ENABLE_SANITIZERS=OFF \
  -DSB_BUNDLE_OGDF=ON \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_SPDLOG="$SRC_DIR/spdlog-src" \
  -DFETCHCONTENT_SOURCE_DIR_OGDF="$SRC_DIR/ogdf-src" \
  -DOGDF_BUILD_TESTS=OFF \
  -DOGDF_BUILD_EXAMPLES=OFF \
  ${CMAKE_RANLIB_ARG:+$CMAKE_RANLIB_ARG}

cmake --build . --target BubbleFinder --parallel "${CPU_COUNT:-1}"
cmake --build . --target snarls_bf    --parallel "${CPU_COUNT:-1}"

cmake --install . || true

mkdir -p "$PREFIX/bin"

for p in BubbleFinder snarls_bf; do
  if [ ! -x "$PREFIX/bin/$p" ]; then
    ex=$(find . -type f -name "$p" -perm -u+x -print -quit || true)
    if [ -n "$ex" ]; then
      install -v -m 0755 "$ex" "$PREFIX/bin/$p"
    else
      echo "ERROR: executable $p not found in build tree" >&2
      exit 1
    fi
  fi
done