#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=${PREFIX}/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=${PREFIX}/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
export CPPFLAGS="$CPPFLAGS -I${PREFIX}/include"

# DEBUG purpose to find boost related libs on travis
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DBoost_NO_BOOST_CMAKE=ON .
make
make install

