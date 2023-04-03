#! /bin/bash

# Export
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
#export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

# Parameters
BUILD_TYPE=Release
BUILD=${PREFIX}/build
PARALLEL=8
BIN=${PREFIX}/bin

# Configure CMake
cmake -B $BUILD -DCMAKE_BUILD_TYPE=$BUILD_TYPE

# Build
cmake --build $BUILD --parallel $PARALLEL --config $BUILD_TYPE

# Copy executables to the bin directory
mkdir -p $BIN
cp $BUILD/smashpp $BIN
cp $BUILD/smashpp-inv-rep $BIN
cp $BUILD/exclude_N $BIN
