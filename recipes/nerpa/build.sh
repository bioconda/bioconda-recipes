#!/usr/bin/env bash

set -eo pipefail

ARCH=$(uname -m)
PREFIX="${PREFIX:-$(pwd)/install}"
BUILD_DIR="${BUILD_DIR:-build}"
SRC_DIR="$(dirname "$0")"

export CC="${CC:-$(command -v gcc || command -v clang)}"
export CXX="${CXX:-$(command -v g++ || command -v clang++)}"
[ -z "$CC" ] && { echo "C compiler not found"; exit 1; }

fix_cxxopts() {
  local header_path="$1"
  if [ -f "$header_path" ] && ! grep -q "#include <cstring>" "$header_path"; then
    sed -i '/#include <vector>/a #include <cstring>' "$header_path"
    echo "$header_path"
  fi
}

detect_generator() {
  if command -v ninja >/dev/null; then
    echo "Ninja"
  else
    echo "Unix Makefiles"
  fi
}

main() {
  find "$SRC_DIR" -name 'cxxopts.hpp' | while read -r file; do
    fix_cxxopts "$file"
  done

  mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR" || exit 1

  cmake -G "$(detect_generator)" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    .. || { echo "CMake configuration failed"; exit 1; }

  if [ "$(detect_generator)" = "Ninja" ]; then
    ninja -j$(nproc) || ninja -j1
  else
    make -j$(nproc) || make -j1
  fi

  cmake --install . --prefix "$PREFIX"
}

main 2>&1 | tee build.log
