#!/bin/bash
set -eu -o pipefail

# pre-built version
if [ "$(uname)" == "Darwin" ]; then
    outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
    mkdir -p $outdir
    mkdir -p $PREFIX/bin
    cp -r bin lib $outdir
    ln -s $outdir/bin/salmon $PREFIX/bin
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export LD_LIBRARY_PATH=${PREFIX}/lib
    cd $SRC_DIR
    mkdir -p build
    sed -i 's/Boost_USE_STATIC_LIBS ON/Boost_USE_STATIC_LIBS OFF/' CMakeLists.txt
    sed -i 's/.\/autogen.sh/CFLAGS=-fPIC CPPFLAGS=-fPIC .\/autogen.sh/' CMakeLists.txt
    sed -i 's/CFLAGS+=${STADEN_LIB}/CFLAGS+=${STADEN_LIB} CFLAGS+=-lz/' CMakeLists.txt
    cd build
    cmake DCMAKE_EXE_LINKER_FLAGS="-L$PREFIX/lib" -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON ..
    make install CFLAGS="-L${PREFIX}/lib -I${PREFIX}/include"
fi
