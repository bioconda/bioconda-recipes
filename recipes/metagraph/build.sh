#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations -Wno-attributes"

ARCH=$(uname -m)
OS=$(uname -s)

# Determine source directory - handle both git source (current dir) and tarball (metagraph/ subdir)
if [ -d "metagraph" ]; then
    SOURCE_DIR="metagraph"
else
    SOURCE_DIR="."
fi

# Initialize submodules if we're in a git repository (for local testing with git_url)
if [ -d "${SOURCE_DIR}/.git" ]; then
    pushd ${SOURCE_DIR}
    git submodule update --init --recursive
    popd
fi

# set version manually for htscodecs
echo '#define HTSCODECS_VERSION_TEXT "1.6.4"' > ${SOURCE_DIR}/external-libraries/htslib/htscodecs/htscodecs/version.h

sed -i.bak 's|Boost_USE_STATIC_LIBS ON|Boost_USE_STATIC_LIBS OFF|' ${SOURCE_DIR}/CMakeLists.txt

pushd ${SOURCE_DIR}/external-libraries/sdsl-lite
./install.sh "${PWD}"
popd

[[ ! -d ${SOURCE_DIR}/build ]] || rm -rf ${SOURCE_DIR}/build
mkdir -p ${SOURCE_DIR}/build
cd ${SOURCE_DIR}/build

# needed for setting up python based integration test environment
export PIP_NO_INDEX=False

CMAKE_PARAMS="-DCMAKE_BUILD_TYPE=Release \
            -DBOOST_ROOT=${PREFIX} \
            -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
            -DCMAKE_INSTALL_PREFIX=${PREFIX} \
            -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=1 \
            -DBUILD_KMC=OFF \
            "

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
