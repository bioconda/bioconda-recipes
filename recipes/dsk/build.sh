#!/bin/bash

if [ `uname` == Darwin ]; then
        export MACOSX_DEPLOYMENT_TARGET=10.9
fi

rm -rf thirdparty/gatb-core
git clone https://github.com/GATB/gatb-core.git thirdparty/gatb-core
cd thirdparty/gatb-core
git checkout d053d0dffdfb9d31e45d42a3da49d2f71c8f87b3
cd ../..

export SHARE_DIR=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
export C_INCLUDE_PATH=${PREFIX}/include

mkdir build
cd build
cmake .. \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCPPUNIT_INCLUDE_DIR=${PREFIX}/include

make -j 2
make install
