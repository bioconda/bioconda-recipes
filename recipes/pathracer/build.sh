#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

normalize_path() {
  current_path="$(pwd)"
  cd "$1"
  normalized_path="$(pwd)"
  cd "$current_path"
  echo "$normalized_path"
}

BUILD_DIR=build_spades
BASEDIR="$(normalize_path "$(pwd)"/"$(dirname "$0")")"

WORK_DIR="$BASEDIR/$BUILD_DIR"
mkdir -p "$WORK_DIR"

cd "$WORK_DIR"
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" "$BASEDIR/src"
make -j4 -C projects/pathracer install
