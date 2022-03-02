#! /bin/bash
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export CXXFLAGS="$CXXFLAGS -fcommon"
export CPPFLAGS="$CXXFLAGS -fcommon"
export CFLAGS="$CFLAGS -fcommon"

cd src 
cmake -D CMAKE_C_FLAGS="$CFLAGS" -D CMAKE_CXX_FLAGS="$CXXFLAGS" .
make -j8 VERBOSE=1
mkdir -p ${PREFIX}/bin
mv GeCo2 ${PREFIX}/bin
mv GeDe2 ${PREFIX}/bin
