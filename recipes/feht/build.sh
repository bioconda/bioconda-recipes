#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"

sudo apt-get install "build-essential"
stack setup
stack update
stack install  --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work