#!/bin/sh

if [ $(uname) == Linux ] ; then
    ## libstdc++ is expected in lib64, so link it there
    if [ ! -d $PREFIX/lib64 ] ; then mkdir $PREFIX/lib64 ; fi
    ln -s $PREFIX/lib/libstdc++.la $PREFIX/lib64/libstdc++.la 
    ln -s $PREFIX/lib/libstdc++.so $PREFIX/lib64/libstdc++.so 
elif [ $(uname) == Darwin ] ; then
    ## define __restrict as empty, since otherwise clang does not
    ## compile with C99 or C11 (this is set by locarna for linking the
    ## Vienna RNAlib, until it offers a cleaner solution)
    extra_config_options="CXXFLAGS='-D __restrict='"
fi

./configure --prefix=$PREFIX --with-vrna=$PREFIX "${extra_config_options}" && \
make -j ${CPU_COUNT} && \
make install
