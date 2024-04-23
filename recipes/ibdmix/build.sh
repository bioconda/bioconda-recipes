#!/bin/bash

cd ${SRC_DIR}/ibdmix/
cmake -S. -Bbuild_conda -G "${CMAKE_GENERATOR}" -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build build_conda --target install
