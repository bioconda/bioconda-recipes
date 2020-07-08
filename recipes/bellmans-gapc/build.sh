#!/bin/sh
export SED="sed"
export SYSTEM_SUFFIX="_linux-gnu"
./configure --with-boost-libdir=$PREFIX/lib/ CPPFLAGS=-I${PREFIX} --prefix=$PREFIX --disable-gsltest

# change compile flags if on OSX
if [ x"$(uname)" == x"Darwin" ]; then
  export SYSTEM_SUFFIX=`cat config.mf |grep "^SYSTEM_SUFFIX" | cut -d "=" -f2 | tr -d " "`
  $SED -E "s/ -D_XOPEN_SOURCE=500 / /" -i config.mf
  $SED -E "s/ -std=c\+\+17 / -std=c\+\+11 /" -i config.mf
fi

make
make install
# remove definition of CXX in user space config file, since this will not match users compiler path,
# instead let conda take care of providing meaningful CXX and CC values.
$SED "s/^CXX = /#CXX = /" -i $PREFIX/share/gapc/config${SYSTEM_SUFFIX}.mf
$SED "s/^CC = /#CC = /" -i $PREFIX/share/gapc/config${SYSTEM_SUFFIX}.mf
