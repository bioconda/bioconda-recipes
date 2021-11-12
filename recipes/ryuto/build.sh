#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

cd extern
cwd=$(pwd)

mkdir libs

unzip clp_mod.zip
tar -xvf lemon_mod.tar.gz

cd clp_mod

echo "========================== CLP =========================="

./configure --enable-static --disable-shared --prefix=$cwd/libs --disable-bzlib --disable-zlib
make
make install

cd ../lemon_mod

echo "========================== LEMON =========================="

mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" -DLEMON_DEFAULT_LP=CLP -DCOIN_ROOT_DIR=$cwd/libs -DCMAKE_INSTALL_PREFIX=$cwd/libs  ..
make
make install 

echo "========================== DONE =========================="

cd ../../..

echo "========================== RYUTO =========================="


aclocal
autoconf
automake --add-missing --foreign

./configure --prefix=$PREFIX --with-htslib="$PREFIX" --with-zlib="$PREFIX" --with-boost="$PREFIX" --with-clp=$cwd/libs --with-staticcoin=$cwd/libs --with-lemon=$cwd/libs

make LIBS+=-lhts
make install
