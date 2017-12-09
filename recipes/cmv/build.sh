#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
pwd
export wdir=`pwd `
cp -r * /tmp
cd /tmp
stack setup
stack update
stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work

