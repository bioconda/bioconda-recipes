#!/bin/bash

set -eu -o pipefail

export CPATH=${PREFIX}/include
export CMAKE_LDFLAGS="-L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak 's/ -Werror / /' src/CMakeLists.txt

cd build
cmake  -DCMAKE_CXX_COMPILER_AR=${AR} \
       -DCMAKE_CXX_COMPILER_RANLIB=${RANLIB} \
       -DINSTALL_PREFIX=TRUE \
       -DCMAKE_INSTALL_PREFIX=${PREFIX}/bin \
       -DCMAKE_BUILD_TYPE=Release \
       -DBOOST_ROOT=${PREFIX} \
       -DBoost_NO_BOOST_CMAKE=TRUE \
       -DBoost_NO_SYSTEM_PATHS=TRUE \
       -DHTSLIB_ROOT=${PREFIX} \
       -DHTSlib_NO_SYSTEM_PATHS=TRUE \
       -DGMP_ROOT=${PREFIX} \
       ..

make install
