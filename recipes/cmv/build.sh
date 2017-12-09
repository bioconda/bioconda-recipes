#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
pwd
export wdir=`pwd`
stack --stack-root $wdir setup
stack --stack-root $wdir update
stack install --stack-root $wdir --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work

