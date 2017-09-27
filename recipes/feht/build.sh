#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib/"
export LD_LIBRARY_PATH="${PREFIX}/lib/"
export LDFLAGS="-L${PREFIX}/lib/"

stack setup
stack update
stack install --local-bin-path ${PREFIX}/bin
#Renaming to bin.
mv ${PREFIX}/bin/feht ${PREFIX}/bin/feht-bin
#Let everyone read and execute the file.
chmod 755 ${PREFIX}/bin/feht-bin
#cleanup
rm -r .stack-work