#!/bin/bash

cd trunk
./autogen.sh
./configure --prefix=$PREFIX --with-boost=$CONDA_PREFIX
make
make install

# let's see if boost -mt libs are listed in the pkgconfig file...
cat $PREFIX/lib/pkgconfig/libMems-1.6.pc

