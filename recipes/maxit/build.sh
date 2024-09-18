#!/bin/bash

set -exo pipefail

# Disable parallel build
export CPU_COUNT=1

ln -s "${CC_FOR_BUILD}" "${BUILD_PREFIX}/bin/gcc"
ln -s "${CXX_FOR_BUILD}" "${BUILD_PREFIX}/bin/g++"

# if [[ $(uname -s) == "Linux" ]]; then
#     ulimit -v 2000000
# fi

make binary "-j${CPU_COUNT}"

unlink "${BUILD_PREFIX}/bin/gcc"
unlink "${BUILD_PREFIX}/bin/g++"

install -d "${PREFIX}/bin"
install ${SRC_DIR}/bin/* "${PREFIX}/bin"
cp -r "${SRC_DIR}/data" "${PREFIX}/data"
