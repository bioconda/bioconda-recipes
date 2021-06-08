#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
if [[ "$(uname)" == Darwin ]]; then
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

make ntedit
mkdir -p $PREFIX/bin
mv ntedit $PREFIX/bin
