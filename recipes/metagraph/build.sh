#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations -Wno-invalid-specialization"
export CFLAGS="${CFLAGS} -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-int-conversion"
export BOOST_INCLUDEDIR="${PREFIX}/include"
export BOOST_LIBRARYDIR="${PREFIX}/lib"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"

ARCH=$(uname -m)
OS=$(uname -s)

# set version manually since we're installing from source and not from a checked out git repo
echo '#define HTSCODECS_VERSION_TEXT "1.6.4"' > metagraph/external-libraries/htslib/htscodecs/htscodecs/version.h


if [[ "${OS}" == "Linux" ]]; then
	CMAKE_PLATFORM_FLAGS=""
	export CXXFLAGS="${CXXFLAGS} -Wno-attributes -Wno-narrowing -Wno-type-limits"
	sed -i.bak 's|Boost_USE_STATIC_LIBS ON|Boost_USE_STATIC_LIBS OFF|' metagraph/CMakeLists.txt
elif [[ "${OS}" == "Darwin" ]]; then
	rm -rf metagraph/external-libraries/KMC/*.bak
	sed -i.bak 's|Boost_USE_STATIC_LIBS ON|Boost_USE_STATIC_LIBS OFF|' metagraph/CMakeLists.txt
	sed -i.bak 's|link_directories(/opt/homebrew/opt/icu4c/lib)|link_directories(${PREFIX}/lib)|' metagraph/CMakeLists.txt
	sed -i.bak 's|link_directories(/usr/local/opt/icu4c/lib)|link_directories(${PREFIX}/lib)|' metagraph/CMakeLists.txt
	CMAKE_PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
	export CXXFLAGS="${CXXFLAGS} -Wno-suggest-destructor-override -Wno-error=deprecated-copy"
fi


pushd metagraph/external-libraries/sdsl-lite
./install.sh "${PWD}"
popd

[[ ! -d metagraph/build ]] || rm -rf metagraph/build
mkdir -p metagraph/build
cd metagraph/build

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

CMAKE_PARAMS="-DCMAKE_BUILD_TYPE=Release \
            -DBOOST_ROOT=${PREFIX} \
            -DOMP_ROOT=${PREFIX} \
            -DCMAKE_PREFIX_PATH=${PREFIX} \
            -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
            -DCMAKE_CXX_COMPILER=${CXX} \
            -DCMAKE_C_COMPILER=${CC} \
            -DCMAKE_INSTALL_PREFIX=${PREFIX} \
            -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=1 \
            -DBUILD_KMC=OFF \
            ${CMAKE_PLATFORM_FLAGS} ${CONFIG_ARGS}"

cmake -S .. -B . ${CMAKE_PARAMS}

BUILD_CMD="make metagraph -j${CPU_COUNT}"

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
