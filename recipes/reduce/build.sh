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
  reduce_src/CMakeLists.txt

# Refer to https://github.com/rlabduke/reduce/issues/60 for `-DHET_DICTIONARY` and `-DHET_DICTOLD` flags
cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DPython_ROOT_DIR="${PREFIX}" \
  -DHET_DICTIONARY="${PREFIX}/share/reduce/reduce_wwPDB_het_dict.txt" \
  -DHET_DICTOLD="${PREFIX}/share/reduce/reduce_het_dict.txt"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"
install -m 644 reduce_wwPDB_het_dict.txt "${PREFIX}/share/reduce"
install -m 755 update_het_dict.py "${PREFIX}/share/reduce"

# Install a shared library file and a Python module
mkdir -p "${SP_DIR}"
install -m 644 build/reduce_src/mmtbx_reduceOrig_ext.so "${SP_DIR}"
install -m 644 build/reduce_src/reduce.py "${SP_DIR}"
