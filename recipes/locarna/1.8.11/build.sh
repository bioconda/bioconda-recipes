#!/bin/sh

if [ $(uname) == Linux ] ; then
    ## libstdc++ is expected in lib64, so link it there
    if [ ! -d $PREFIX/lib64 ] ; then mkdir $PREFIX/lib64 ; fi
    ln -s $PREFIX/lib/libstdc++.la $PREFIX/lib64/libstdc++.la 
    ln -s $PREFIX/lib/libstdc++.so $PREFIX/lib64/libstdc++.so 
fi

## Currently conda build uses gcc-4.8, which does not turn on C11.
## Consequnetly, Vienna RNAlib is build without C11 support and we
## must not set stdc here. (Anyway, C11 would currently not work
## for the MacOSX build.)
extra_config_options=--enable-STDC=no

./configure --prefix=$PREFIX --with-vrna=$PREFIX "${extra_config_options}" && \
make -j ${CPU_COUNT} && \
make -j ${CPU_COUNT} check && \
make install
