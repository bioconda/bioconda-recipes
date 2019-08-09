#!/bin/bash

if [ `uname` == Darwin ]; then
        export MACOSX_DEPLOYMENT_TARGET=10.9
fi

export SHARE_DIR=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
export C_INCLUDE_PATH=${PREFIX}/include

mkdir build
cd build
cmake .. \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCPPUNIT_INCLUDE_DIR=${PREFIX}/include

make -j 2
make install
