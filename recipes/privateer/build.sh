#!/bin/bash

set -exo pipefail

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -frtti -include cstdint"

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic"
fi

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

sed -i '/^project(/a set(PYBIND11_FINDPYTHON ON CACHE BOOL "Use FindPython")' CMakeLists.txt
sed -i '/^project(/a find_package(Python3 COMPONENTS Interpreter Development REQUIRED)' CMakeLists.txt
sed -i '/^project(/a find_package(pybind11 CONFIG REQUIRED)' CMakeLists.txt
sed -i 's|add_subdirectory(${CMAKE_SOURCE_DIR}/dependencies/pybind11)||' CMakeLists.txt
sed -i 's|${PYTHON_LIBRARY}||g' CMakeLists.txt
sed -i 's|${CMAKE_SOURCE_DIR}/dependencies/gemmi/include|${GEMMI_INCLUDE_DIR}|' CMakeLists.txt

mkdir -p "${SP_DIR}/privateer"
touch "${SP_DIR}/privateer/__init__.py"
sed -i 's|TARGETS privateer_core DESTINATION ${PROJECT_SOURCE_DIR}|TARGETS privateer_core DESTINATION $ENV{SP_DIR}/privateer|' CMakeLists.txt
sed -i 's|DESTINATION ${PROJECT_SOURCE_DIR}|DESTINATION ${CMAKE_INSTALL_PREFIX}|g' CMakeLists.txt

source ccp4.envsetup-sh

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DPython3_EXECUTABLE="${PYTHON}" \
    -DPython3_ROOT_DIR="${PREFIX}" \
    -DGEMMI_INCLUDE_DIR="${PREFIX}/include/gemmi" \
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
install -m 644 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/env_vars.sh"
install -m 644 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"
