#! /bin/bash

# Export
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
#export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

# Parameters
BUILD_TYPE=Release
BUILD=${SRC_DIR}/build
PARALLEL=4
BIN=${PREFIX}/bin

if [[ "${target_platform}" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Configure CMake
cmake -B $BUILD \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCRYFA_VERSION_OVERRIDE=${PKG_VERSION}

# Build
cmake --build $BUILD --parallel $PARALLEL --config $BUILD_TYPE

# Copy executables to the bin directory
mkdir -p $BIN
cp $BUILD/cryfa $BIN
cp $BUILD/keygen $BIN
