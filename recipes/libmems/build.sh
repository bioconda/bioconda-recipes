#!/bin/bash

cd trunk

# Some patches are required, but the source has DOS line endings which 
# require the --binary argument to patch, which is not provided through conda 
# Best option seems to be to convert line endings then apply patches here
sed -i.bak $'s/\r$//' libMems/ProgressiveAligner.cpp
sed -i.bak $'s/\r$//' libMems/AbstractMatch.h

patch -p 1 < $RECIPE_DIR/libMems.1.patch
patch -p 1 < $RECIPE_DIR/libMems.2.patch

./autogen.sh
./configure --prefix=$PREFIX --with-boost=$CONDA_PREFIX
make
make install

# let's see if boost -mt libs are listed in the pkgconfig file...
cat $PREFIX/lib/pkgconfig/libMems-1.6.pc

