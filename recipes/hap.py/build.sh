#!/bin/bash
sed -i.bak -e '/^configure_files.*libz/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*tabix/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bgzip/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bcftools/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*samtools/s/^/#/' CMakeLists.txt
mkdir -p build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_INCLUDEDIR=$PREFIX/include/boost -DBOOST_LIBRARYDIR=$PREFIX/lib
make
rm -f lib/libhts*so
make install
