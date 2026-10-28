#!/bin/bash

# This uses deprecated functions, can't treat warning as errors
sed -i.bak "s/-Werror //" src/cmake/cxx.cmake

# external htslib.a means we need -lz and co
sed -i.bak "s/\${LIBLZMA_LIBRARIES}/\${LIBLZMA_LIBRARIES} \${LIBBZIP2_LIBRARIES} \${LIBZLIB_LIBRARIES}/;s/libhts.a/libhts.so/" src/cmake/GetHtslib.cmake
sed -i.bak "53d" CMakeLists.txt

mkdir build
pushd build
export HTSLIB_INSTALL_PATH=${PREFIX}
cmake ../ -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_C_COMPILER=${CC} -DBOOST_ROOT=${BUILD_PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DHTSLIB_INSTALL_PATH=${PREFIX} -DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
make 
make install
