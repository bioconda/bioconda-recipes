#!/bin/bash
sed -i.bak -e '/^configure_files.*libz/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*tabix/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bgzip/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bcftools/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*samtools/s/^/#/' CMakeLists.txt
# Avoid build errors with samtools/curses by skipping
sed -i.bak 's/make -j4 -C samtools/#make -j4 -C samtools/' external/make_dependencies.sh
mkdir -p build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_INCLUDEDIR=$PREFIX/include/boost -DBOOST_LIBRARYDIR=$PREFIX/lib
make
rm -f lib/libhts*so
make install
