#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib -pthread -lpthread"
export CPPFLAGS="-I${PREFIX}/include"
export GCCPATH=`which gcc`

stack setup
stack update
stack install --with-gcc="$GCCPATH"--extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work

