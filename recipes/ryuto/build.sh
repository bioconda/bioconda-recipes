#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"


./reset_autogen.sh

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
cmake -Wdev --debug-output --trace -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" -DLEMON_DEFAULT_LP=CLP -DCOIN_ROOT_DIR=$SRC_DIR/libraries_to_install/Clp-1.16.11 -DCMAKE_INSTALL_PREFIX=`pwd`  ..
make
make install 

echo "========================== CMAKE LOG =========================="
cat CMakeFiles/CMakeOutput.log
echo "========================== CMAKE ERR =========================="
cat CMakeFiles/CMakeError.log
echo "========================== CMAKE VAL =========================="
cat CMakeCache.txt

cd ../../..

./configure --prefix=$PREFIX --with-htslib="$PREFIX" --with-zlib="$PREFIX" --with-boost="$PREFIX" --with-clp=`pwd`/libraries_to_install/Clp-1.16.11 --with-staticcoin=`pwd`/libraries_to_install/Clp-1.16.11 --with-lemon=`pwd`/libraries_to_install/lemon-f51c01a1b88e/build

make LIBS+=-lhts
make install
