#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"


CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

cd libraries_to_install

unzip Clp-1.16.11.zip
tar -xvf lemon-f51c01a1b88e_mod.tar.gz

cd Clp-1.16.11

./configure --enable-static --disable-shared --prefix=`pwd` --disable-bzlib --disable-zlib
make
make install

cd ../lemon-f51c01a1b88e

mkdir build
cd build
cmake -DLEMON_DEFAULT_LP=CLP -DCOIN_ROOT_DIR=`pwd`/../../Clp-1.16.11 -DCMAKE_INSTALL_PREFIX=`pwd` ${CMAKE_PLATFORM_FLAGS[@]} ..
make
make install

cd ../../..

./configure --prefix=$PREFIX --with-htslib="$PREFIX" --with-zlib="$PREFIX" --with-boost="$PREFIX" --with-staticcoin=`pwd`/libraries_to_install/Clp-1.16.11 --with-lemon=`pwd`/libraries_to_install/lemon-f51c01a1b88e/build

make LIBS+=-lhts
make install
