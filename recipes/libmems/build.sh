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
  
# Some boost versions require boost_system to be the last in the list of libraries when linking...
sed -i -e 's/-lboost_system //' -e 's/-lrt/-lboost_system -lrt/' $PREFIX/lib/pkgconfig/libMems-1.6.pc

