#!/bin/bash
sed -i.bak -e '/^configure_files.*libz/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*tabix/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bgzip/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bcftools/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*samtools/s/^/#/' CMakeLists.txt

# Do not build "external dependencies". This is wrong to begin with and compilers and such are skipped anyway
sed -i.bak "26,33d" CMakeLists.txt

# Fix location of libz.a
sed -i.bak "s#ZLIB_LIBRARIES \${CMAKE_BINARY_DIR}#ZLIB_LIBRARIES $PREFIX#" CMakeLists.txt

# Some boost libraries need -lrt
sed -i.bak "82i \
                        rt\n" CMakeLists.txt

mkdir -p build
cat CMakeLists.txt
cd build
export BOOST_ROOT=$PREFIX
export HTSLIB_INCLUDE_DIR=$PREFIX/include
export HTSLIB_LIBRARY=$PREFIX/lib
cmake ../ -DCMAKE_C_COMPILER=$CC \
          -DCMAKE_CXX_COMPILER=$CXX \
          -DCMAKE_INSTALL_PREFIX=$PREFIX \
          -DHTSLIB_INCLUDE_DIR=$PREFIX/include \
          -DHTSLIB_LIBRARY=$PREFIX/lib \
          -DBOOST_ROOT=${PREFIX}
make
make install
