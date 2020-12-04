#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# RESET AUTOMAKE just in case for RYUTO

./reset_autogen.sh

# Build static libraries. Sadly Lemon from Forge cannot be linked to CLP correctly. So this is a workaround for now.

echo "Recipe Dir"
echo $RECIPE_DIR

cd $RECIPE_DIR

unzip clp_mod.zip
tar -xvf lemon_mod.tar.gz

cd clp_mod

echo "========================== CLP =========================="

./configure --enable-static --disable-shared --prefix=`pwd` --disable-bzlib --disable-zlib
make
make install



cd ../lemon_mod


echo "========================== LEMON =========================="

mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake" -DLEMON_DEFAULT_LP=CLP -DCOIN_ROOT_DIR=$RECIPE_DIR/clp_mod -DCMAKE_INSTALL_PREFIX=$RECIPE_DIR/lemon_mod  ..
echo "========================== cmake done"
make
echo "========================== make done"
make install 
echo "========================== make install done"

echo "========================== CMAKE LOG =========================="
cat CMakeFiles/CMakeOutput.log
echo "========================== CMAKE ERR =========================="
cat CMakeFiles/CMakeError.log
echo "========================== CMAKE VAL =========================="
cat CMakeCache.txt

# RUN RYUTO

cd $SRC_DIR
echo "========================== RYUTO =========================="
./configure --prefix=$PREFIX --with-htslib="$PREFIX" --with-zlib="$PREFIX" --with-boost="$PREFIX" --with-clp=$RECIPE_DIR/clp_mod --with-staticcoin=$RECIPE_DIR/clp_mod --with-lemon=$RECIPE_DIR/lemon_mod
echo "========================== configure down"
make LIBS+=-lhts
make install
