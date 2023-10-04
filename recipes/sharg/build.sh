#!/bin/bash

set -eux -o pipefail

echo "cmake_minimum_required(VERSION 3.14)
project(sharg NONE)
include (\${SHARG_CLONE_DIR}/build_system/sharg-install.cmake)" > CMakeLists.txt

cmake -DSHARG_CLONE_DIR="${SRC_DIR}" \
      -DSHARG_INCLUDE_DIR="${SRC_DIR}/include" \
      -DSHARG_SUBMODULES_DIR="${SRC_DIR}" \
      -DSHARG_DEPENDENCY_INCLUDE_DIRS="${SRC_DIR}/submodules/tool_description_lib/src" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" .

make install
