#!/bin/bash

# set up directory for building boost compiled dependencies
# see
# https://github.com/conda-forge/boost-cpp-feedstock/blob/master/recipe/build.sh
# https://github.com/boostorg/program_options/blob/develop/.travis.yml
git clone --depth 1 https://github.com/boostorg/boost.git boost
pushd boost
rmdir libs/program_options libs/filesystem libs/iostreams libs/system libs/timer libs/chrono
git clone --depth 50 https://github.com/boostorg/program_options.git libs/program_options
git clone --depth 50 https://github.com/boostorg/filesystem.git libs/filesystem
git clone --depth 50 https://github.com/boostorg/iostreams.git libs/iostreams
git clone --depth 50 https://github.com/boostorg/system.git libs/system
git clone --depth 50 https://github.com/boostorg/timer.git libs/timer
git clone --depth 50 https://github.com/boostorg/chrono.git libs/chrono
git submodule update -q --init tools/boostdep
git submodule update -q --init tools/build
git submodule update -q --init tools/inspect
python2 tools/boostdep/depinst/depinst.py program_options --include example
python2 tools/boostdep/depinst/depinst.py filesystem --include example
python2 tools/boostdep/depinst/depinst.py iostreams --include example
python2 tools/boostdep/depinst/depinst.py system --include example
python2 tools/boostdep/depinst/depinst.py timer --include example
python2 tools/boostdep/depinst/depinst.py chrono --include example

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
./bootstrap.sh --prefix="${BOOST_BUILT}" --with-libraries=program_options,filesystem,iostreams,system,timer,chrono --with-toolset=gcc
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

# build spydrpick, statically linking boost manually
curl -o FindTBB.cmake https://raw.githubusercontent.com/Kitware/VTK/master/CMake/FindTBB.cmake
export CMAKE_MODULE_PATH=${SRC_DIR}
mkdir build && pushd build
cmake -DBoost_INCLUDE_DIR=${BOOST_BUILT}/include -DBoost_LIBRARY_DIR=${BOOST_BUILT}/lib ..
make
install ${PREFIX}/bin bin/aracne bin/SpydrPick
popd
