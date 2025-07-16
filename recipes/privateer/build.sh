#!/bin/bash

set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -frtti"

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

# if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
#   export CPU_COUNT=$(( CPU_COUNT * 70 / 100 ))
# fi

sed -i.bak 's|${PYTHON_LIBRARY}||g' "CMakeLists.txt"

source ccp4.envsetup-sh

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DPYBIND11_INCLUDE_DIR="${PREFIX}/include/pybind11" \
    -DPYTHON_INCLUDE_DIRS="${PREFIX}/include/python${PY_VER}" \
    -DMMDB2DEP="${PREFIX}/lib/libmmdb2${SHLIB_EXT}" \
    -DCCP4CDEP="${PREFIX}/lib/libccp4srs${SHLIB_EXT}" \
    -DCCP4SRSDEP="${PREFIX}/lib/libccp4c${SHLIB_EXT}" \
    -DCLIPPERCOREDEP="${PREFIX}/lib/libclipper-core${SHLIB_EXT}" \
    -DCLIPPERMMDBDEP="${PREFIX}/lib/libclipper-mmdb${SHLIB_EXT}" \
    -DCLIPPERMINIMOLDEP="${PREFIX}/lib/libclipper-minimol${SHLIB_EXT}" \
    -DCLIPPERCONTRIBDEP="${PREFIX}/lib/libclipper-contrib${SHLIB_EXT}" \
    -DCLIPPERCCP4DEP="${PREFIX}/lib/libclipper-ccp4${SHLIB_EXT}" \
    -DCLIPPERCIFDEP="${PREFIX}/lib/libclipper-cif${SHLIB_EXT}"

cmake --build build --clean-first --parallel "${CPU_COUNT}"
cmake --install build --parallel "${CPU_COUNT}"

mkdir -p ${PREFIX}/share/privateer/data/
mkdir -p ${PREFIX}/share/privateer/results/
cp -r ${SRC_DIR}/data/* ${PREFIX}/share/privateer/data/

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp -f "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/env_vars.sh"
cp -f "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"
