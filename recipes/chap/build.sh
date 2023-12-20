#!/bin/bash

# Ugly hack since cmake things that tmglib.so should be present, even though
# that is used for testing lapack and is not present in the final build
# 
# Just chop the offending chunks out of the cmake targets...

lapack_targets=$(find $PREFIX/lib/cmake -name lapack-targets.cmake)
lapack_targets_release=$(find $PREFIX/lib/cmake -name lapack-targets-release.cmake)

sed -i.bak -e 's/foreach(_expectedTarget blas lapack tmglib)/foreach(_expectedTarget blas lapack)/' ${lapack_targets}
sed -i.bak -e '/add_library(tmglib SHARED IMPORTED)/,+15d' ${lapack_targets}
sed -i.bak -e '/set_property(TARGET tmglib APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)/,+5d' ${lapack_targets_release}

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install

mv ${PREFIX}/chap/bin/* ${PREFIX}/bin


