#!/bin/bash

export CFLAGS="-I$CONDA_PREFIX/include"
export LDFLAGS="-L$CONDA_PREFIX/lib"
export CPATH=${PREFIX}/include


git submodule update --init
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_CONAN=OFF \
    -DENABLE_PERF_TESTING=OFF -D ENABLE_PYTHON=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-L${CONDA_PREFIX}/lib -L${PREFIX:-}/lib -L${PREFIX}/hdf5/lib/plugin/ -lzstd"  \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}  ..

make -j
make install

PLUGIN_PATH=${PREFIX}/hdf5/lib/plugin/


mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d

echo "export HDF5_PLUGIN_PATH='${PLUGIN_PATH}'" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}-env_vars.sh"
echo 'unset HDF5_PLUGIN_PATH' > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-env_vars.sh"
