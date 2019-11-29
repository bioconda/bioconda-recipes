#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include


# stack relies on $HOME, so fake it:
mkdir -p fake-home
export HOME=$PWD/fake-home
export STACK_ROOT="$HOME/.stack"
stack setup --local-bin-path ${PREFIX}/bin --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --with-gmp-libraries ${PREFIX}/lib
stack install --local-bin-path ${PREFIX}/bin --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --with-gmp-libraries ${PREFIX}/lib

#cleanup
rm -r .stack-work
