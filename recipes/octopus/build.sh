#!/bin/bash

set -eu -o pipefail

export CPATH=${PREFIX}/include
export CMAKE_LDFLAGS="-L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib

# https://github.com/luntergroup/octopus/issues/38
export HTSLIB_ROOT=${PREFIX}/lib

# Ignore compiler warnings
sed -i.bak '556i\
    -Wno-maybe-uninitialized
' CMakeLists.txt

sed -i.bak 's/ -Werror / /' src/CMakeLists.txt

cd build
cmake  -DCMAKE_CXX_COMPILER_AR=${AR} \
       -DCMAKE_CXX_COMPILER_RANLIB=${RANLIB} \
       -DINSTALL_PREFIX=ON \
       -DCMAKE_INSTALL_PREFIX=${PREFIX}/bin \
       -DINSTALL_ROOT=ON \
       -DCMAKE_BUILD_TYPE=Release \
       -DBOOST_ROOT=${PREFIX} \
       -DBoost_NO_SYSTEM_PATHS=ON \
       ..

make install
