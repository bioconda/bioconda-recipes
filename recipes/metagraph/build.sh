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
    CMAKE_PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    export CXXFLAGS="${CXXFLAGS} -Wno-suggest-destructor-override -Wno-error=deprecated-copy"
fi

if [[ "${target_platform}" == "osx-64" ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

CMAKE_PARAMS="-DBUILD_KMC=OFF \
            -DBOOST_ROOT=${BUILD_PREFIX} \
            -DJEMALLOC_ROOT=${BUILD_PREFIX} \
            -DOMP_ROOT=${BUILD_PREFIX} \
            -DCMAKE_PREFIX_PATH=${PREFIX} \
            -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
            -DCMAKE_BUILD_TYPE=Release \
            ${CMAKE_PLATFORM_FLAGS} \
            -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=1 \
            -DCMAKE_INSTALL_PREFIX=${PREFIX}"

cmake ${CMAKE_PARAMS} ..

BUILD_CMD="make VERBOSE=1 -j $(($(getconf _NPROCESSORS_ONLN) - 1)) metagraph"

${BUILD_CMD}

make install

### Make Protein binary version

make clean

cmake ${CMAKE_PARAMS} -DCMAKE_DBG_ALPHABET=Protein ..

${BUILD_CMD}

make install

### Adding symlink to default DNA binary version

pushd ${PREFIX}/bin
ln -s metagraph_DNA metagraph
popd

