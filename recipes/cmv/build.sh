#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LDFLAGS="-L${PREFIX}/lib -pthread -lpthread"
export CPPFLAGS="-I${PREFIX}/include"
export GCCPATH=$PREFIX/bin/gcc

stack setup --local-bin-path ${PREFIX}/bin
stack update
stack install --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work

