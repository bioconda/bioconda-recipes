#!/bin/sh

if [ $(uname) == Linux ] ; then
    ## libstdc++ is expected in lib64, so link it there
    if [ ! -d $PREFIX/lib64 ] ; then mkdir $PREFIX/lib64 ; fi
    ln -s $PREFIX/lib/libstdc++.la $PREFIX/lib64/libstdc++.la 
    ln -s $PREFIX/lib/libstdc++.so $PREFIX/lib64/libstdc++.so 
fi

./configure --prefix=$PREFIX --with-vrna=$PREFIX "${extra_config_options}" && \
make -j ${CPU_COUNT} && \
make -j ${CPU_COUNT} check && \
make install
