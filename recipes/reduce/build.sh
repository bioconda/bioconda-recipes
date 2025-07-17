#!/bin/bash

set -exo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup"
fi

sed -i.bak \
  's|target_link_libraries(mmtbx_reduceOrig_ext PRIVATE reducelib ${Boost_LIBRARIES} ${PYTHON_LIBRARIES})|target_link_libraries(mmtbx_reduceOrig_ext PRIVATE reducelib ${Boost_LIBRARIES})|' \
  CMakeLists.txt

# Refer to https://github.com/rlabduke/reduce/issues/60 for `-DHET_DICTIONARY` and `-DHET_DICTOLD` flags
cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DPython_ROOT_DIR="${PREFIX}" \
  -DPYTHON_SITE_PACKAGES="${SP_DIR}" \
  -DHET_DICTIONARY="${PREFIX}/reduce_wwPDB_het_dict.txt" \
  -DHET_DICTOLD="${PREFIX}/reduce_get_dict.txt"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"
