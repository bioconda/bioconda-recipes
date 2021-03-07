#!/usr/bin/env bash

pushd metagraph/external-libraries/sdsl-lite
./install.sh $PWD
popd

[ ! -d metagraph/build ]  || rm -r metagraph/build
mkdir -p metagraph/build
cd metagraph/build

if [[ $OSTYPE == linux* ]]; then
    CMAKE_PLATFORM_FLAGS=""
    export CXXFLAGS="${CXXFLAGS} -Wno-attributes"
elif [[ $OSTYPE == darwin* ]]; then
    CMAKE_PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15"
    export CXXFLAGS="${CXXFLAGS} -Wno-suggest-destructor-override -Wno-error=deprecated-copy"
fi

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

cmake -DBUILD_KMC=OFF \
      -DBOOST_ROOT=${BUILD_PREFIX} \
      -DJEMALLOC_ROOT=${BUILD_PREFIX} \
      -DOMP_ROOT=${BUILD_PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
      -DCMAKE_BUILD_TYPE=Release \
      ${CMAKE_PLATFORM_FLAGS} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} ..

make VERBOSE=1 -j $(($(getconf _NPROCESSORS_ONLN) - 1)) metagraph

make install
