#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
CXXFLAGS="$CXXFLAGS";
LDFLAGS="$LDFLAGS";
if [ `uname` == Darwin ] ; then
# enable c++11 support
    #echo;
    echo "PREFIX/lib";
    ls -l $PREFIX/lib;
    echo "PREFIX/lib/pkgconfig";
    ls -l $PREFIX/lib/pkgconfig;
    echo "PREFIX/lib/pkgconfig/icu*";
    cat $PREFIX/lib/pkgconfig/icu*;
    #cat $PREFIX/lib/pkgconfig/RNAlib*;
    #echo "otool"
    #otool -L $PREFIX/lib/libboost_program_options.dylib
    #echo;
    MACOSX_VERSION_MIN=10.6
    #CC=clang
    #CXX=clang++
    CC=gcc
    CXX=g++
    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++ -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -stdlib=libstdc++ -mmacosx-version-min=${MACOSX_VERSION_MIN} -L${PREFIX}/lib"
    #CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    #LDFLAGS="${LDFLAGS} -stdlib=libc++ -mmacosx-version-min=${MACOSX_VERSION_MIN} -L${PREFIX}/lib"
else ## linux
    # add -fopenmp to compilation due to viennarna setup
    CC=gcc
    CXX=g++
    CXXFLAGS="-fopenmp"
fi

export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}
export CC=${CC}
export CXX=${CXX}

./configure --prefix=$PREFIX \
            --with-RNA=$PREFIX \
            --with-boost=$PREFIX \
            --disable-multithreading \
            ${extra_config_options} \
            
# replace libs with static full path for OSX
if [ `uname` == Darwin ] ; then
  # replace all dependency libs
  for l in RNA boost_regex boost_program_options boost_filesystem boost_system; do
    sed -i.bak "s|-l${l}|${PREFIX}/lib/lib${l}.a|g" src/Makefile
    sed -i.bak "s|-l${l}|${PREFIX}/lib/lib${l}.a|g" tests/Makefile
  done
  grep boost src/Makefile*;
fi         

make && \
make install
