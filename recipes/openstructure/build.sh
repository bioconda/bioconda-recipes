#!/bin/bash

# Use sed on code instead of patch, so we do not have to fix the library dir
# for every OST version.
sed -i.tmp 's/lib64/lib/g' cmake_support/OST.cmake
# Use sed above patch as it should work for multiple OST versions.
sed -i.tmp 's/"@Python_EXECUTABLE@"/`which python`/' scripts/ost_config.in

if test "${target_platform}" = "osx-64"; then
    ost_cmake_extra_args="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
else if test "${target_platform}" = "linux-64"; then
         ost_cmake_extra_args="-DEIGEN3_INCLUDE_DIR=${BUILD_PREFIX}/include/eigen3 \
                     -DSQLITE3_LIBRARY=${PREFIX}/lib/libsqlite3${SHLIB_EXT} \
                     -DSQLITE3_INCLUDE_DIR=${PREFIX}/include \
                     -DZLIB_LIBRARY=${PREFIX}/lib/libz${SHLIB_EXT} \
                     -DZLIB_INCLUDE_DIR=${PREFIX}/include \
                     -DPNG_LIBRARY=${PREFIX}/lib/libpng${SHLIB_EXT} \
                     -DPNG_INCLUDE_DIR=${PREFIX}/include \
                     -DFFTW_LIBRARY=${PREFIX}/lib/libfftw3${SHLIB_EXT} \
                     -DFFTW_INCLUDE_DIR=${PREFIX}/include \
                     -DTIFF_LIBRARY=${PREFIX}/lib/libtiff${SHLIB_EXT} \
                     -DTIFF_INCLUDE_DIR=${PREFIX}/include"
     else
         echo "unsupported target platform: '${target_platform}'"
         exit 1
     fi
fi

cmake -Bbuild \
      -G "${CMAKE_GENERATOR}" \
      -DPREFIX="${PREFIX}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DENABLE_MM=OFF \
      -DCOMPILE_TMTOOLS=1 \
      -DENABLE_GFX=OFF \
      -DENABLE_GUI=OFF \
      -DENABLE_INFO=OFF \
      -DCMAKE_CXX_COMPILER_VERSION="${CMAKE_CXX_COMPILER_VERSION}" \
      -DPython_EXECUTABLE="${PYTHON}" \
      -DPYTHON_MODULE_PATH="${SP_DIR}" \
      -DUSE_RPATH=1 \
      ${ost_cmake_extra_args}

cmake --build build --target all ${MAKEFLAGS}

curl -OL https://files.wwpdb.org/pub/pdb/data/monomers/components.cif.gz
${SRC_DIR}/build/stage/bin/chemdict_tool create ${SRC_DIR}/components.cif.gz compounds.chemlib pdb
${SRC_DIR}/build/stage/bin/chemdict_tool update ${SRC_DIR}/modules/conop/data/charmm.cif compounds.chemlib charmm
cmake -Bbuild -G "${CMAKE_GENERATOR}" -DCOMPOUND_LIB=${SRC_DIR}/compounds.chemlib
cmake --build build --target install ${MAKEFLAGS}
cmake --build build --target check ${MAKEFLAGS}
