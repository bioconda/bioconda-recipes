#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cmake -DSEQAN3_CLONE_DIR="${SRC_DIR}" \
      -DSEQAN3_INCLUDE_DIR="${SRC_DIR}/include" \
      -DSEQAN3_SUBMODULES_DIR="${SRC_DIR}" \
      -DSEQAN3_DEPENDENCY_INCLUDE_DIRS="${SRC_DIR}/submodules/sdsl-lite/include;${SRC_DIR}/submodules/cereal/include" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" .

make install
