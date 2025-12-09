#!/bin/bash
set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -frtti"

# Set environment variables to locate dependency libraries in `build/`
if [[ "${target_platform}" == "linux-"* ]]; then
  export LD_LIBRARY_PATH="${PWD}/build:${LD_LIBRARY_PATH}"
elif [[ "${target_platform}" == "osx-"* ]]; then
  export DYLD_LIBRARY_PATH="${PWD}/build:${DYLD_LIBRARY_PATH}"
fi

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

pushd api/doxy-sphinx
doxygen coot-api-dox.cfg
popd

mkdir -p "${PREFIX}/share/doxy-sphinx"
cp -r api/doxy-sphinx/* "${PREFIX}/share/doxy-sphinx"

# Boost 1.86.0 still needs `system` component
sed -i 's|Boost COMPONENTS iostreams|Boost COMPONENTS iostreams system|' CMakeLists.txt
sed -i 's|Boost::thread Boost::iostreams|Boost::thread Boost::iostreams Boost::system|' CMakeLists.txt

sed -i '/find_package(RDKit CONFIG COMPONENTS RDGeneral REQUIRED)/a\
set_target_properties(RDKit::rdkit_base PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${RDKit_INCLUDE_DIRS}")' CMakeLists.txt

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
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
  -DPython_SITELIB="${SP_DIR}" \
  -DMAKE_COOT_HEADLESS_API_PYI=ON \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build --parallel "${CPU_COUNT}"

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 755 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/coot-headless_activate.sh"
install -m 755 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/coot-headless_deactivate.sh"
install -m 755 "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/coot-headless_activate.fish"
install -m 755 "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/coot-headless_deactivate.fish"
