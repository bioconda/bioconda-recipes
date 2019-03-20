#!/bin/bash

# set up directory for building boost compiled dependencies
# see
# https://github.com/conda-forge/boost-cpp-feedstock/blob/master/recipe/build.sh
# https://github.com/boostorg/program_options/blob/develop/.travis.yml
git clone --depth 1 --single-branch --branch boost-1.69.0 https://github.com/boostorg/boost.git boost
pushd boost
rmdir libs/program_options libs/filesystem libs/regex libs/system
git clone --depth 50 https://github.com/boostorg/program_options.git libs/program_options
git clone --depth 50 https://github.com/boostorg/filesystem.git libs/filesystem
git clone --depth 50 https://github.com/boostorg/system.git libs/system
git clone --depth 50 https://github.com/boostorg/regex.git libs/regex
git submodule update -q --init libs/algorithm
git submodule update -q --init libs/graph
git submodule update -q --init tools/boostdep
git submodule update -q --init tools/build
git submodule update -q --init tools/inspect
python2 tools/boostdep/depinst/depinst.py program_options --include example
python2 tools/boostdep/depinst/depinst.py filesystem --include example
python2 tools/boostdep/depinst/depinst.py system --include example
python2 tools/boostdep/depinst/depinst.py regex --include example
python2 tools/boostdep/depinst/depinst.py graph --include example
python2 tools/boostdep/depinst/depinst.py algorithm --include example

CXXFLAGS="${CXXFLAGS} -fPIC"
INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"
LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"

cat <<EOF > tools/build/src/site-config.jam
using gcc : : ${CXX} ;
EOF

# compile and install boost
BOOST_BUILT="${SRC_DIR}/boost_built"
mkdir $BOOST_BUILT
./bootstrap.sh --prefix="${BOOST_BUILT}" --with-libraries=program_options,filesystem,regex,system --with-toolset=gcc
./b2 -q \
    variant=release \
    address-model="${ARCH}" \
    architecture=x86 \
    debug-symbols=off \
    threading=multi \
    runtime-link=shared \
    link=static,shared \
    toolset=gcc \
    include="${INCLUDE_PATH}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LINKFLAGS}" \
    --layout=system \
    -j"${CPU_COUNT}" \
    install
popd

# get submodules
rmdir gatb-core
git clone https://github.com/GATB/gatb-core.git
pushd gatb-core
git checkout 0a106c474bb315b550b57848b33e03c7dee57705
popd

rmdir pstreams
git clone https://github.com/jwakely/pstreams.git
pushd pstreams
git checkout 2a064aad673a06ed7deda2b0e2d1663646aaff59
popd

# build unitig-counter
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release -DBoost_INCLUDE_DIR=${BOOST_BUILT}/include -DBoost_LIBRARY_DIR=${BOOST_BUILT}/lib -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make VERBOSE=1
make install
popd
