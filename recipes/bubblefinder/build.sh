set -euo pipefail
set -x

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-1}"
export MAKEFLAGS="-j${CPU_COUNT:-1}"

export CMAKE_PREFIX_PATH="${PREFIX}:${CMAKE_PREFIX_PATH:-}"
export CMAKE_INCLUDE_PATH="${PREFIX}/include:${CMAKE_INCLUDE_PATH:-}"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib:${CMAKE_LIBRARY_PATH:-}"

rm -rf "$SRC_DIR/external/gbz"
mkdir -p "$SRC_DIR/external/gbz"

mv "$SRC_DIR/sdsl-lite-src" "$SRC_DIR/external/gbz/sdsl-lite"
mv "$SRC_DIR/libhandlegraph-src" "$SRC_DIR/external/gbz/libhandlegraph"
mv "$SRC_DIR/gbwt-src" "$SRC_DIR/external/gbz/gbwt"
mv "$SRC_DIR/gbwtgraph-src" "$SRC_DIR/external/gbz/gbwtgraph"

mkdir -p "$SRC_DIR/external/gbz/sdsl-lite/external"
rm -rf "$SRC_DIR/external/gbz/sdsl-lite/external/libdivsufsort"
rm -rf "$SRC_DIR/external/gbz/sdsl-lite/external/googletest"
mv "$SRC_DIR/libdivsufsort-src" "$SRC_DIR/external/gbz/sdsl-lite/external/libdivsufsort"
mv "$SRC_DIR/googletest-src" "$SRC_DIR/external/gbz/sdsl-lite/external/googletest"

cd "$SRC_DIR"
rm -rf build
mkdir -p build
cd build

extra_cmake_args=""
if [[ "${target_platform:-}" == osx-* ]]; then
  cat > ranlib-wrapper.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REAL="${REAL_RANLIB:-${RANLIB:-ranlib}}"
tmp="$(mktemp)"

set +e
"$REAL" -no_warning_for_no_symbols "$@" 2>"$tmp"
rc=$?
set -e

if [ $rc -ne 0 ] && grep -qiE 'unknown|unrecognized|illegal option' "$tmp"; then
  : >"$tmp"
  set +e
  "$REAL" "$@" 2>"$tmp"
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
  extra_cmake_args="-DCMAKE_RANLIB=${RANLIB}"
fi

cmake ${CMAKE_ARGS:-} .. \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSB_ENABLE_LTO=OFF \
  -DSB_ENABLE_SANITIZERS=OFF \
  -DSB_BUNDLE_OGDF=ON \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_SPDLOG="$SRC_DIR/vendor-log-src" \
  -DFETCHCONTENT_SOURCE_DIR_OGDF="$SRC_DIR/ogdf-src" \
  -DOGDF_BUILD_TESTS=OFF \
  -DOGDF_BUILD_EXAMPLES=OFF \
  ${extra_cmake_args}

cmake --build . --target BubbleFinder --parallel "${CPU_COUNT:-1}"
cmake --build . --target snarls_bf --parallel "${CPU_COUNT:-1}"

mkdir -p "$PREFIX/bin"
install -m 0755 ./BubbleFinder "$PREFIX/bin/BubbleFinder"
install -m 0755 ./snarls_bf "$PREFIX/bin/snarls_bf"