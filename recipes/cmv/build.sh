#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LDFLAGS="-L${PREFIX}/lib -pthread -lpthread"
export CPPFLAGS="-I${PREFIX}/include"
export GCCPATH=$PREFIX/bin/gcc

stack setup --with-gcc="$GCCPATH" --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib:/usr/lib:/usr/lib64 --local-bin-path ${PREFIX}/bin
stack update
stack install --with-gcc="$GCCPATH" --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib:/usr/lib:/usr/lib64 --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work

