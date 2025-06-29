#!/bin/bash
set -exo pipefail

if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
  export CPU_COUNT=$(( CPU_COUNT * 70 / 100 ))
fi

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -frtti"

if [[ "${target_platform}" == "osx-"* ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

sed -i.bak 's|find_package(Python 3.12.4|find_package(Python 3|' CMakeLists.txt
sed -i.bak '/find_package(RDKit CONFIG COMPONENTS RDGeneral REQUIRED)/a\
set_target_properties(RDKit::rdkit_base PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${RDKit_INCLUDE_DIRS}")' CMakeLists.txt
rm -rf *.bak

cmake -S . -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DPython_EXECUTABLE="${PYTHON}" \
  -Dnanobind_DIR="${SP_DIR}/nanobind/cmake" \
  -DBOOST_ROOT="${PREFIX}" \
  -DEIGEN3_INCLUDE_DIR="${PREFIX}/include/eigen3" \
  -DGSL_ROOT_DIR="${PREFIX}" \
  -DRDKIT_ROOT="${PREFIX}" \
  -DRDKit_DIR="${PREFIX}/lib/cmake/rdkit" \
  -DRDKit_INCLUDE_DIRS="${PREFIX}/include/rdkit" \
  -DFFTW2_INCLUDE_DIRS="${PREFIX}/fftw2/include" \
  -DFFTW2_LIBRARY="${PREFIX}/fftw2/lib/libfftw${SHLIB_EXT}" \
  -DRFFTW2_LIBRARY="${PREFIX}/fftw2/lib/librfftw${SHLIB_EXT}" \
  -DMMDB2_INCLUDE_DIR="${PREFIX}/include/mmdb2" \
  -DMMDB2_LIBRARY="${PREFIX}/lib/libmmdb2${SHLIB_EXT}" \
  -DSSM_INCLUDE_DIR="${PREFIX}/include/ssm" \
  -DSSM_LIBRARY="${PREFIX}/lib/libssm${SHLIB_EXT}" \
  -DCLIPPER-CORE_INCLUDE_DIR="${PREFIX}/include/clipper" \
  -DCLIPPER-CORE_LIBRARY="${PREFIX}/lib/libclipper-core${SHLIB_EXT}" \
  -DCLIPPER-MMDB_INCLUDE_DIR="${PREFIX}/include/clipper" \
  -DCLIPPER-MMDB_LIBRARY="${PREFIX}/lib/libclipper-mmdb${SHLIB_EXT}" \
  -DCLIPPER-CCP4_INCLUDE_DIR="${PREFIX}/include/clipper" \
  -DCLIPPER-CCP4_LIBRARY="${PREFIX}/lib/libclipper-ccp4${SHLIB_EXT}" \
  -DCLIPPER-MINIMOL_LIBRARY="${PREFIX}/lib/libclipper-minimol${SHLIB_EXT}" \
  -DCLIPPER-CONTRIB_LIBRARY="${PREFIX}/lib/libclipper-contrib${SHLIB_EXT}" \
  -DCLIPPER-CIF_LIBRARY="${PREFIX}/lib/libclipper-cif${SHLIB_EXT}" \
  -DPYTHON_SITE_PACKAGES="${SP_DIR}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  ${CONFIG_ARGS}


cmake --build build --clean-first --target coot_headless_api -j "${CPU_COUNT}"
cmake --install build -j "${CPU_COUNT}"

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp -f "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/env_vars.sh"
cp -f "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/env_vars.sh"
