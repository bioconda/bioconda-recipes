#!/bin/sh
./configure --with-boost-libdir=$PREFIX/lib/ CPPFLAGS=-I${PREFIX} --prefix=$PREFIX --disable-gsltest
make
make install
# remove definition of CXX in user space config file, since this will not match users compiler path,
# instead let conda take care of providing meaningful CXX and CC values.
sed "s/^CXX = /#CXX = /" -i $PREFIX/share/gapc/config_linux-gnu.mf
sed "s/^CC = /#CC = /" -i $PREFIX/share/gapc/config_linux-gnu.mf
