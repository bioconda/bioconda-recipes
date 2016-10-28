#!/bin/bash
<<<<<<< HEAD

export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

stack setup
stack update
stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work
=======
stack setup
stack build
>>>>>>> 41ec3f1... Added RNAlien recipe
