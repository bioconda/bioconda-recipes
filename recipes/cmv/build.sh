#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib -pthread -lpthread"
export CPPFLAGS="-I${PREFIX}/include"
export GCCPATH=$PREFIX/bin/gcc

stack setup --with-gcc="$GCCPATH" --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin --ghc-options="-threaded"
stack update
stack install --with-gcc="$GCCPATH" --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin --ghc-options="-threaded"
#cleanup
rm -r .stack-work

