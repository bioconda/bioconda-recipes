#!/bin/bash
set -euxo pipefail

export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_PREFIX_PATH=${PREFIX}"
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"

if [[ "${target_platform}" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
