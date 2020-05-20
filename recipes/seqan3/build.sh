#!/bin/bash

echo "cmake_minimum_required(VERSION 3.7)
project(seqan3 NONE)
include (\${SEQAN3_CLONE_DIR}/build_system/seqan3-install.cmake)" >> CMakeLists.txt

cmake -DSEQAN3_CLONE_DIR="${SRC_DIR}" \
      -DSEQAN3_INCLUDE_DIR="${SRC_DIR}/include" \
      -DSEQAN3_SUBMODULES_DIR="${SRC_DIR}" \
      -DSEQAN3_DEPENDENCY_INCLUDE_DIRS="${SRC_DIR}/submodules/range-v3/include;${SRC_DIR}/submodules/sdsl-lite/include;${SRC_DIR}/submodules/cereal/include" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" .

make install
