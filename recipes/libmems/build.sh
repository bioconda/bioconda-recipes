#!/bin/bash -x

# Some patches are required, but the source has DOS line endings which 
# require the --binary argument to patch, which is not provided through conda 
# Best option seems to be to convert line endings then apply patches here

sed -i.bak $'s/\r$//' trunk/libMems/ProgressiveAligner.cpp
sed -i.bak $'s/\r$//' trunk/libMems/AbstractMatch.h
patch -p 0 -u < $RECIPE_DIR/patch.1
patch -p 0 -u < $RECIPE_DIR/patch.2

PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${CONDA_PREFIX}/lib/pkgconfig

cd trunk
./autogen.sh
./configure --prefix=$PREFIX 
make
make install

# let's see if boost -mt libs are listed in the pkgconfig file...
cat $PREFIX/lib/pkgconfig/libMems-1.6.pc && exit 1

