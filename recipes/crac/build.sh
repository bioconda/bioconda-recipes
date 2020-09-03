#!/bin/bash

### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="-L${PREFIX}/lib"
# Compiler flags
unset CXXFLAGS
export CXXFLAGS="-I${PREFIX}/include"
# fixed the version before C++11 due to deprecated use of the register keyword
export CPPFLAGS="-std=c++03"

# if troubleshooting with zlib
export CPATH=${PREFIX}/include

# Others troubleshooting
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# compile Crac 
./configure
make CXX="$CXX $CXXFLAGS" CPPFLAGS="$CPPFLAGS" install ROOT="."
make check
sudo make install
make installcheck

# cp executables
mkdir -pv "$PREFIX"/bin/
cp -pf CRAC "$PREFIX"/bin/
