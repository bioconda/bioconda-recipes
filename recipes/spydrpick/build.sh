#!/bin/bash

# set up directory for building boost compiled dependencies
# see
# https://github.com/conda-forge/boost-cpp-feedstock/blob/master/recipe/build.sh
# https://github.com/boostorg/program_options/blob/develop/.travis.yml
git clone --depth 1 --single-branch --branch boost-1.69.0 https://github.com/boostorg/boost.git boost
pushd boost
rmdir libs/program_options libs/filesystem libs/iostreams libs/system libs/timer libs/chrono
git clone --depth 50 https://github.com/boostorg/program_options.git libs/program_options
git clone --depth 50 https://github.com/boostorg/filesystem.git libs/filesystem
git clone --depth 50 https://github.com/boostorg/iostreams.git libs/iostreams
git clone --depth 50 https://github.com/boostorg/system.git libs/system
git clone --depth 50 https://github.com/boostorg/timer.git libs/timer
git clone --depth 50 https://github.com/boostorg/chrono.git libs/chrono
git submodule update -q --init libs/accumulators
git submodule update -q --init libs/functional
git submodule update -q --init tools/boostdep
git submodule update -q --init tools/build
git submodule update -q --init tools/inspect
python2 tools/boostdep/depinst/depinst.py program_options --include example
python2 tools/boostdep/depinst/depinst.py filesystem --include example
python2 tools/boostdep/depinst/depinst.py iostreams --include example
python2 tools/boostdep/depinst/depinst.py system --include example
python2 tools/boostdep/depinst/depinst.py timer --include example
python2 tools/boostdep/depinst/depinst.py chrono --include example
python2 tools/boostdep/depinst/depinst.py accumulators --include example
python2 tools/boostdep/depinst/depinst.py functional --include example

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

# set up other dependencies
rmdir externals/apegrunt
git clone https://github.com/santeripuranen/apegrunt.git externals/apegrunt
pushd externals/apegrunt
git checkout 889986582ab6be9e1edfc307e7cfc25a705cfa2b
git apply ${RECIPE_DIR}/0001-use-no-apple-in-apegrunt.patch ${RECIPE_DIR}/0002-AVX-to-SSE3-in-apegrunt.patch
popd

# build spydrpick
export CMAKE_MODULE_PATH=${RECIPE_DIR}
mkdir build && pushd build
cmake -DTBB_ROOT=${PREFIX} -DBoost_INCLUDE_DIR=${BOOST_BUILT}/include -DBoost_LIBRARY_DIR=${BOOST_BUILT}/lib ..
make VERBOSE=1
install -d ${PREFIX}/bin
install bin/SpydrPick ${PREFIX}/bin
popd
