!/bin/bash

set -ex

cd esme_vfd_gds

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

make VERBOSE=1 -j${CPU_COUNT}

make install

mkdir -p $PREFIX/lib/hdf5/plugin
SRC_LIB=$(ls $PREFIX/lib/libhdf5_vfd_gds.so* | head -1)
cp "$SRC_LIB" $PREFIX/lib/hdf5/plugin/libhdf5_vfd_gds.so
