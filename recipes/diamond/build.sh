#!/bin/bash

sed -i.bak 's/-march=native/-march=x86-64/' CMakeLists.txt

mkdir build
cd build


cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_LIBRARY_PATH="$CONDA_PREFIX;$PREFIX;" \
      -DBOOST_NO_SYSTEM_PATHS=on \
      -DWITH_ZSTD=on \
      -DZSTD_LIBRARY=$CONDA_PREFIX/lib/libzstd.a \
      -DZSTD_INCLUDE_DIR=$CONDA_PREFIX/include/ \
      -DBLAST_LIB_DIR=$CONDA_PREFIX/lib/ncbi-blast+ \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=""

cmake --build . --config Release --target install

# Reference link:
# https://github.com/conda/conda-recipes/blob/master/boost/build.sh
