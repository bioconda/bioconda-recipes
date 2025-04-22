#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

ARCH=$(uname -m)

sed -i.bak 's|VERSION 2.8.2|VERSION 3.5|' metagraph/CMakeLists.txt.in
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' metagraph/CMakeListsKMC.txt.in
sed -i.bak 's|VERSION 2.8.11|VERSION 3.5|' metagraph/external-libraries/sdsl-lite/CMakeLists.txt
sed -i.bak 's|VERSION 2.4.4|VERSION 3.5|' metagraph/external-libraries/sdsl-lite/external/libdivsufsort/CMakeLists.txt
sed -i.bak 's|VERSION 2.6.4|VERSION 3.5|' metagraph/external-libraries/sdsl-lite/external/googletest/CMakeLists.txt
sed -i.bak 's|VERSION 2.6.4|VERSION 3.5|' metagraph/external-libraries/sdsl-lite/external/googletest/googletest/CMakeLists.txt
sed -i.bak 's|VERSION 2.6.4|VERSION 3.5|' metagraph/external-libraries/sdsl-lite/external/googletest/googlemock/CMakeLists.txt
sed -i.bak 's|VERSION 2.6|VERSION 3.5|' metagraph/external-libraries/DYNAMIC/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' metagraph/external-libraries/zlib/CMakeLists.txt
sed -i.bak 's|VERSION 3.1.3|VERSION 3.5|' metagraph/external-libraries/caches/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.11|VERSION 3.5|' metagraph/external-libraries/eigen/CMakeLists.txt
sed -i.bak 's|VERSION 3.0.2|VERSION 3.5|' metagraph/external-libraries/folly/CMakeLists.txt
sed -i.bak 's|VERSION 3.1|VERSION 3.5|' metagraph/external-libraries/hopscotch-map/CMakeLists.txt
sed -i.bak 's|VERSION 3.1|VERSION 3.5|' metagraph/external-libraries/ordered-map/CMakeLists.txt

if [[ `uname -m` == "aarch64" ]]; then
	sed -i.bak 's|g++|${CXX}|' metagraph/external-libraries/KMC/makefile
	sed -i.bak 's|/usr/local/gcc-6.3.0/bin/g++|${CXX}|' metagraph/external-libraries/KMC/makefile_mac
	sed -i.bak 's|-m64||' metagraph/external-libraries/KMC/makefile
	sed -i.bak 's|-m64||' metagraph/external-libraries/KMC/makefile_mac
	sed -i.bak 's|-m64||' metagraph/CMakeListsKMC.txt.in
	rm -rf metagraph/external-libraries/KMC/*.bak
fi

if [[ `uname -m` == "arm64" ]]; then
	sed -i.bak 's|g++|${CXX}|' metagraph/external-libraries/KMC/makefile
	sed -i.bak 's|/usr/local/gcc-6.3.0/bin/g++|${CXX}|' metagraph/external-libraries/KMC/makefile_mac
	sed -i.bak 's|-m64||' metagraph/external-libraries/KMC/makefile
	sed -i.bak 's|-m64||' metagraph/external-libraries/KMC/makefile_mac
	sed -i.bak 's|-m64||' metagraph/CMakeListsKMC.txt.in
	rm -rf metagraph/external-libraries/KMC/*.bak
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi

sed -i.bak 's|-O2|-O3|' metagraph/CMakeLists.txt

pushd metagraph/external-libraries/sdsl-lite
./install.sh $PWD
popd

[[ ! -d metagraph/build ]]  || rm -r metagraph/build
mkdir -p metagraph/build
cd metagraph/build

if [[ $OSTYPE == linux* ]]; then
    CMAKE_PLATFORM_FLAGS=""
    export CXXFLAGS="${CXXFLAGS} -Wno-attributes -Wno-narrowing"
    export CONFIG_ARGS=""
elif [[ $OSTYPE == darwin* ]]; then
    CMAKE_PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    export CXXFLAGS="${CXXFLAGS} -Wno-implicit-function-declaration -Wno-suggest-destructor-override -Wno-error=deprecated-copy"
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

if [[ "${target_platform}" == "osx-64" ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

CMAKE_PARAMS="-DBUILD_KMC=OFF \
            -DBOOST_ROOT=${PREFIX} \
            -DJEMALLOC_ROOT=${PREFIX} \
            -DOMP_ROOT=${PREFIX} \
            -DCMAKE_PREFIX_PATH=${PREFIX} \
            -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
            -DCMAKE_BUILD_TYPE=Release \
            ${CMAKE_PLATFORM_FLAGS} \
            -DCMAKE_CXX_COMPILER=${CXX} \
            -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=1 \
            -DCMAKE_INSTALL_PREFIX=${PREFIX} \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	    -DWITH_AVX=OFF \
            ${CONFIG_ARGS}"

if [[ $OSTYPE == darwin* ]]; then
	CMAKE_PARAMS="${CMAKE_PARAMS} -DCMAKE_CXX_FLAGS=${CXXFLAGS}"
fi

if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
	CMAKE_PARAMS="${CMAKE_PARAMS} -DWITH_MSSE42=OFF"
fi

cmake -S .. -B . ${CMAKE_PARAMS}

BUILD_CMD="make VERBOSE=1 -j $(($(getconf _NPROCESSORS_ONLN) - 1)) metagraph"

${BUILD_CMD}

make install

### Make Protein binary version

make clean

cmake -S .. -B . ${CMAKE_PARAMS} -DCMAKE_DBG_ALPHABET=Protein

${BUILD_CMD}

make install

### Adding symlink to default DNA binary version
pushd ${PREFIX}/bin
chmod 0755 metagraph_DNA
ln -sf metagraph_DNA metagraph
popd
