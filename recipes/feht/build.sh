#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

stack setup
stack update
stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
mv ${PREFIX}/bin/feht ${PREFIX}/bin/feht-bin
chmod 755 ${PREFIX}/bin/feht
#cleanup
rm -r .stack-work