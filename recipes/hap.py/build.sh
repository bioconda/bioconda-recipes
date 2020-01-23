#!/bin/bash
sed -i.bak -e '/^configure_files.*libz/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*tabix/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bgzip/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*bcftools/s/^/#/' CMakeLists.txt
sed -i.bak -e '/^configure_files.*samtools/s/^/#/' CMakeLists.txt
# Avoid build errors with samtools/curses by skipping
sed -i.bak 's/make -j4 -C samtools/#make -j4 -C samtools/' external/make_dependencies.sh

# Do not build "external dependencies". This is wrong to begin with and compilers and such are skipped anyway
sed -i.bak "26,33d" CMakeLists.txt

mkdir -p build
cd build
export BOOST_ROOT=$PREFIX
cmake ../ -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=${PREFIX}
make
#rm -f lib/libhts*so
make install
