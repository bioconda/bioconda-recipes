#!/bin/bash
sed -i.bak -e '/^configure_files.*libz/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*tabix/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bgzip/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bcftools/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*samtools/s/^/#/' CMakeLists.txt

# Do not build "external dependencies". This is wrong to begin with and compilers and such are skipped anyway
sed -i.bak "26,33d" CMakeLists.txt

mkdir -p build
cd build
export BOOST_ROOT=$PREFIX
export HTSLIB_ROOT=$PREFIX
cmake ../ -DCMAKE_C_COMPILER=$CC \
          -DCMAKE_CXX_COMPILER=$CXX \
          -DCMAKE_INSTALL_PREFIX=$PREFIX \
          -DHTSLIB_ROOT=$PREFIX \
          -DBOOST_ROOT=${PREFIX}
make
make install
