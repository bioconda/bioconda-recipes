#!/bin/bash
set -ex

export CC=mpicc
export CXX=mpicxx
export FC=mpifort

cd esme_hdf5

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
    -DZLIB_ROOT="${PREFIX}" \
    -DSZIP_ROOT="${PREFIX}" \
    -DBUILD_TESTING=OFF \
    -DHDF5_BUILD_EXAMPLES=OFF \
    -DHDF5_BUILD_CPP_WRAPPERS=OFF \
    -DHDF5_BUILD_HL_LIB=OFF \
    -DHDF5_BUILD_TOOLS=ON \
    -DHDF5_BUILD_UTILS=ON

make -j ${CPU_COUNT}
make install

sed -i.bak '/^Libs\.private/d' ${PREFIX}/lib/pkgconfig/hdf5.pc
rm -f ${PREFIX}/lib/pkgconfig/hdf5.pc.bak

if [ "${BUILD_VFD_GDS:-0}" = "1" ]; then
  cd ../../esme_vfd_gds
  rm -rf build
  mkdir build
  cd build
  cmake .. \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DHDF5_ROOT=${PREFIX}
  make -j${CPU_COUNT}
  make install
  mkdir -p ${PREFIX}/lib/hdf5/plugin
  cp libhdf5_vfd_gds.so* ${PREFIX}/lib/hdf5/plugin/ || true
fi
