set -euo pipefail
set -x

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-1}"
export MAKEFLAGS="-j${CPU_COUNT:-1}"

export CMAKE_PREFIX_PATH="${PREFIX}:${CMAKE_PREFIX_PATH:-}"
export CMAKE_INCLUDE_PATH="${PREFIX}/include:${CMAKE_INCLUDE_PATH:-}"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib:${CMAKE_LIBRARY_PATH:-}"

mkdir -p build
cd build

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
  -DOGDF_ENABLE_SHARED=ON \
  -DOGDF_LP_SOLVER=COIN

cmake --build . -- -j${CPU_COUNT:-1}
cmake --install . || true

for p in BubbleFinder snarls_bf; do
  if [ ! -x "$PREFIX/bin/$p" ]; then
    ex=$(find . -type f -name "$p" -perm -u+x -print -quit || true)
    if [ -n "$ex" ]; then
      install -v -m 0755 "$ex" "$PREFIX/bin/$p"
    fi
  fi
done
