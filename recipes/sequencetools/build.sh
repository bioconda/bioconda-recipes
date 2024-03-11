#!/bin/bash
# export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LDFLAGS="-L${PREFIX}/lib"
# export CPPFLAGS="-I${PREFIX}/include"

stack install --local-bin-path ${PREFIX}/bin --system-ghc
#cleanup
# rm -r .stack-work

