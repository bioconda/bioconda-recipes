#!/bin/bash
# build unitig-counter
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DBoost_INCLUDE_DIR=${PREFIX}/include -DBoost_LIBRARY_DIR=${PREFIX}/lib -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make VERBOSE=1
install -d $PREFIX/bin
install unitig-counter cdbg-ops ext/gatb-core/bin/Release/gatb-h5dump $PREFIX/bin
popd
