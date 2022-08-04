#!/bin/bash -x

export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${PREFIX}/lib/pkgconfig

cd trunk
./autogen.sh
./configure --prefix=$PREFIX
make
make install

# Some boost versions require boost_system to be the last in the list of libraries when linking...
sed -i -e 's/-lboost_system //' -e 's/-lrt/-lboost_system -lrt/' $PREFIX/lib/pkgconfig/libMems-1.6.pc
