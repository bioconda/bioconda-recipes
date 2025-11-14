#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

cd esme_hdf5

./configure --prefix="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-szlib="${PREFIX}" \
            --enable-fortran \
            --enable-parallel \
            --enable-threadsafe \
            --enable-unsupported \
            --enable-optimization=high \
            --enable-build-mode=production \
            --disable-dependency-tracking \
            --enable-static=no \
            --disable-doxygen-doc

make -j ${CPU_COUNT}

make install

if [ "${BUILD_VFD_GDS:-0}" = "1" ]; then
  cd ../esme_vfd_gds

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
