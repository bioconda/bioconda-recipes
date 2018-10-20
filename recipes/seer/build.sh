#!/bin/bash

# build gzstream for static linking
pushd gzstream
make clean
make CXX="$CXX $CXXFLAGS" CPPFLAGS="$CPPFLAGS -I. -I$PREFIX/include" AR="$AR cr"
popd

# build boost program options for static linking
# see
# https://github.com/conda-forge/boost-cpp-feedstock/blob/master/recipe/build.sh
# https://github.com/boostorg/program_options/blob/develop/.travis.yml
pushd boost
python2 tools/boostdep/depinst/depinst.py program_options --include example

CXXFLAGS="${CXXFLAGS} -fPIC"
INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"
LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"

cat <<EOF > tools/build/src/site-config.jam
using gcc : custom : ${CXX} ;
EOF

BOOST_BUILT="${SRC_DIR}/boost_built"
mkdir $BOOST_BUILT
./bootstrap.sh --prefix="${BOOST_BUILT}" --with-libraries=program_options --with-toolset=gcc
./b2 -q \
    variant=release \
    address-model="${ARCH}" \
    architecture=x86 \
    debug-symbols=off \
    threading=multi \
    runtime-link=shared \
    link=static,shared \
    toolset=gcc-custom \
    include="${INCLUDE_PATH}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LINKFLAGS}" \
    --layout=system \
    -j"${CPU_COUNT}" \
    install
popd

# build seer, statically linking boost manually
pushd src
make CXXFLAGS="$CXXFLAGS" \
   SEER_LDLIBS="-L../gzstream -L${BOOST_BUILT}/lib -L/usr/local/hdf5/lib -lhdf5 -lgzstream -lz -larmadillo -Wl,-Bstatic -lboost_program_options -Wl,-Bdynamic -lopenblas -llapack -lpthread" \
   MAP_LDLIBS="-L${BOOST_BUILT}/lib -Wl,-Bstatic -lboost_program_options -Wl,-Bdynamic -lpthread" \
   COMBINE_LDLIBS="-L${BOOST_BUILT}/lib -L../gzstream -L/lib -lgzstream -lz -Wl,-Bstatic -lboost_program_options -Wl,-Bdynamic" \
   FILTER_LDLIBS="-L${BOOST_BUILT}/lib -Wl,-Bstatic -lboost_program_options -Wl,-Bdynamic" \
   CPPFLAGS="-I${BOOST_BUILT}/include -I../gzstream -I../dlib -I/usr/local/hdf5/include -D DLIB_NO_GUI_SUPPORT=1 -D DLIB_USE_BLAS=1 -D DLIB_USE_LAPACK=1 -DARMA_DONT_USE_WRAPPER -DARMA_USE_HDF5=1"
make install BINDIR="${PREFIX}/bin"
popd
