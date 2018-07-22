#!/bin/bash
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

#Adust path to copy executables too with prefix
sed -i.bak "s#usr/bin/#${PREFIX}/bin#g"
sed -i.bak "s#usr/share/#${PREFIX}/share#g"

# Fix shebangs
sed -i.bak "s:usr/bin/perl:usr/bin/env perl:" *.pl

#Create dir for shared reference files
mkdir -p $PREFIX/share

# schmutzi uses non-standard bamtools functions that aren't part of the normal library
cd lib
rmdir bamtools
git clone https://github.com/pezmaster31/bamtools
mkdir bamtools/build
cd bamtools/build
cmake ..
make
cd ../..

# Build libgab
rmdir libgab
git clone https://github.com/grenaud/libgab
cd libgab
make BAMTOOLSINC=${PREFIX}/include/bamtools BAMTOOLSLIB=${PREFIX}/lib
cd ../..

make install

