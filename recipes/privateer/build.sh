#!/bin/bash

set -exo pipefail

export CXXFLAGS="${CXXFLAGS} -frtti -include cstdint"

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined -Wl,--export-dynamic -Wl,--unresolved-symbols=ignore-all"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic -flat_namespace"
fi

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

export CCP4_MASTER=${SRC_DIR}
export CCP4=$CCP4_MASTER/dependencies
export CLIBD="${PREFIX}/share/privateer"
export CINCL="${PREFIX}/include"
export CLIBS="${PREFIX}/lib/libccp4"
export CLIBD_MON="${CLIBD}/monomers/"
export PRIVATEERSRC="${CCP4_MASTER}/src/privateer"
export PRIVATEERDATA="${CCP4_MASTER}/data"
export PRIVATEERRESULTS="${CCP4_MASTER}/results"

mkdir -p "${CLIBD}"
mkdir -p "${CLIBD_MON}"

sed -i '/^project(/a set(PYBIND11_FINDPYTHON ON CACHE BOOL "Use FindPython")' CMakeLists.txt
sed -i '/^project(/a find_package(Python3 COMPONENTS Interpreter Development REQUIRED)' CMakeLists.txt
sed -i '/^project(/a find_package(pybind11 CONFIG REQUIRED)' CMakeLists.txt
sed -i 's|add_subdirectory(${CMAKE_SOURCE_DIR}/dependencies/pybind11)||' CMakeLists.txt
sed -i 's|${CMAKE_SOURCE_DIR}/dependencies/gemmi/include|${GEMMI_INCLUDE_DIR}|' CMakeLists.txt

# Modify installation paths except python modules
sed -i 's|TARGETS privateer_lib LIBRARY DESTINATION ${PROJECT_SOURCE_DIR}|TARGETS privateer_lib LIBRARY DESTINATION lib|' CMakeLists.txt
sed -i 's|TARGETS privateer_exec DESTINATION ${PROJECT_SOURCE_DIR}|TARGETS privateer_exec RUNTIME DESTINATION bin|' CMakeLists.txt

# Modify python module installation paths
mkdir -p "${SP_DIR}/privateer"
cp -f "${SRC_DIR}/src/privateer/"*.py "${SP_DIR}/privateer/"
cp -rf "${SRC_DIR}/src/privateer/utils" "${SP_DIR}/privateer/"
sed -i 's|TARGETS privateer_core DESTINATION ${PROJECT_SOURCE_DIR}|TARGETS privateer_core DESTINATION $ENV{SP_DIR}/privateer|' CMakeLists.txt
sed -i 's|TARGETS privateer_modelling DESTINATION ${PROJECT_SOURCE_DIR}|TARGETS privateer_modelling DESTINATION $ENV{SP_DIR}/privateer|' CMakeLists.txt

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
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

# Install activation and deactivation scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 755 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/privateer_activate.sh"
install -m 755 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/privateer_deactivate.sh"
install -m 755 "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/privateer_activate.fish"
install -m 755 "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/privateer_deactivate.fish"
