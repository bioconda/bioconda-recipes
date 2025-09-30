#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -O3 -Wno-unused-but-set-variable -Wno-implicit-function-declaration -Wno-int-conversion"
export JEMALLOC_LIBRARY="${PREFIX}/lib"
export JEMALLOC_INCLUDE_DIR="${PREFIX}/include"
export BOOST_INCLUDEDIR="${PREFIX}/include"
export BOOST_LIBRARYDIR="${PREFIX}/lib"

ARCH=$(uname -m)
OS=$(uname -s)

if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
	sed -i.bak 's|"-mavx"|""|' CMakeListsKMC.txt.in
	sed -i.bak 's|-mavx2||' CMakeListsKMC.txt.in
	sed -i.bak 's|-mfma||' CMakeListsKMC.txt.in
	sed -i.bak 's|"-msse2"|""|' CMakeListsKMC.txt.in
	sed -i.bak 's|"-msse4.1"|""|' CMakeListsKMC.txt.in
	sed -i.bak 's|-m64||' CMakeListsKMC.txt.in
	sed -i.bak 's|g++|${CXX}|' external-libraries/KMC/makefile
	sed -i.bak 's|-m64||' external-libraries/KMC/makefile
	rm -rf external-libraries/KMC/*.bak
	sed -i.bak 's|-mcx16||' CMakeLists.txt
	rm -f *.bak
fi

if [[ "${OS}" == "Linux" ]]; then
	CMAKE_PLATFORM_FLAGS=""
	export CXXFLAGS="${CXXFLAGS} -Wno-attributes -Wno-narrowing -Wno-type-limits"
	export CONFIG_ARGS=""
	sed -i.bak 's|Boost_USE_STATIC_LIBS ON|Boost_USE_STATIC_LIBS OFF|' CMakeLists.txt
	sed -i.bak 's|HTSCODECS_VERSION_TEXT|HTSCODECS_VERSION|' external-libraries/htslib/htscodecs/htscodecs/htscodecs.c
	rm -f external-libraries/htslib/htscodecs/htscodecs/*.bak
elif [[ "${OS}" == "Darwin" ]]; then
	sed -i.bak 's|/usr/local/gcc-6.3.0/bin/g++|${CXX}|' external-libraries/KMC/makefile_mac
 	sed -i.bak 's|-m64||' external-libraries/KMC/makefile_mac
	rm -rf external-libraries/KMC/*.bak
	CMAKE_PLATFORM_FLAGS="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
	export CXXFLAGS="${CXXFLAGS} -Wno-implicit-function-declaration -Wno-suggest-destructor-override -Wno-error=deprecated-copy -D_LIBCPP_DISABLE_AVAILABILITY"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

sed -i.bak 's|-O2|-O3|' CMakeLists.txt
sed -i.bak 's|-lpthread|-pthread|' CMakeLists.txt

pushd external-libraries/sdsl-lite
./install.sh "${PWD}"
popd

[[ ! -d metagraph/build ]] || rm -rf build
mkdir -p build
cd build

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

CMAKE_PARAMS="-DCMAKE_BUILD_TYPE=Release \
            -DBOOST_ROOT=${PREFIX} \
            -DJEMALLOC_ROOT=${PREFIX} \
            -DOMP_ROOT=${PREFIX} \
            -DCMAKE_PREFIX_PATH=${PREFIX} \
            -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
            -DCMAKE_CXX_COMPILER=${CXX} \
            -DCMAKE_C_COMPILER=${CC} \
            -DCMAKE_INSTALL_PREFIX=${PREFIX} \
            -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=1 \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DBUILD_KMC=OFF \
			-DWITH_AVX=OFF -Wno-dev -Wno-deprecated --no-warn-unused-cli \
            ${CMAKE_PLATFORM_FLAGS} ${CONFIG_ARGS}"

if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
	CMAKE_PARAMS="${CMAKE_PARAMS} -DWITH_MSSE42=OFF"
fi

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
