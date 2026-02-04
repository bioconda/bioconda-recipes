#!/bin/bash
set -ex

export CC=mpicc
export CXX=mpicxx
export FC=mpifort

cd "${SRC_DIR}/esme_hdf5"

mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_Fortran_COMPILER="${FC}" \
    -DBUILD_SHARED_LIBS=ON \
    -DHDF5_ENABLE_PARALLEL=ON \
    -DHDF5_BUILD_FORTRAN=ON \
    -DHDF5_ENABLE_THREADSAFE=ON \
    -DHDF5_ALLOW_UNSUPPORTED:BOOL=ON \
    -DHDF5_ENABLE_ZLIB_SUPPORT=ON \
    -DHDF5_ENABLE_SZIP_SUPPORT=ON \
    -DBUILD_TESTING=OFF \
    -DHDF5_BUILD_EXAMPLES=OFF \
    -DHDF5_BUILD_CPP_WRAPPERS=OFF \
    -DHDF5_BUILD_HL_LIB=ON \
    -DHDF5_BUILD_TOOLS=ON \
    -DHDF5_BUILD_UTILS=ON

make -j ${CPU_COUNT}
make install

sed -i.bak '/^Libs.private/d' ${PREFIX}/lib/pkgconfig/hdf5.pc
rm -f ${PREFIX}/lib/pkgconfig/hdf5.pc.bak

if [ "${BUILD_VFD_GDS:-0}" = "1" ]; then
  cd "${SRC_DIR}/esme_vfd_gds"

  mkdir build
  cd build

  export CMAKE_POLICY_VERSION_MINIMUM=3.5
  export CMAKE_POLICY_DEFAULT_CMP0146=OLD

  cmake .. \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DHDF5_ROOT=${PREFIX} \
    -DHDF5_INCLUDE_DIR=${PREFIX}/include \
    -DHDF5_VFD_GDS_CUFILE_DIR=${PREFIX} \
    -DHDF5_VFD_GDS_CUFILE_LIB=${PREFIX}/lib/libcufile.so

  make -j${CPU_COUNT}

  make install

  mkdir -p ${PREFIX}/lib/hdf5/plugin

  SRC_LIB=$(ls ${PREFIX}/lib/libhdf5_vfd_gds.so* | head -1)

  cp "$SRC_LIB" ${PREFIX}/lib/hdf5/plugin/libhdf5_vfd_gds.so
fi
