#!/bin/bash

if [[ ${target_platform} == "linux-aarch64" ]]; then
  wget https://raw.githubusercontent.com/DLTcollab/sse2neon/refs/tags/v1.8.0/sse2neon.h -P ${SRC_DIR}/src/
  sed -i 's/<x86intrin\.h>/\"sse2neon\.h\"/g' src/fmath.hpp
fi

# Install
cmake -H. -Bbuild_conda -G "${CMAKE_GENERATOR}" -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build build_conda --target install
