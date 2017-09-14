#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
#explicititly set dictory for GHC download
export STACK_ROOT="${PREFIX}/stack"
stack setup --local-bin-path ${PREFIX}/bin
stack update
stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work
rm -r "${PREFIX}/stack"
