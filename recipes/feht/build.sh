#!/bin/bash
export LIBRARY_PATH="${PREFIX}/usr/lib/"
export LD_LIBRARY_PATH="${PREFIX}/usr/lib/"
export LDFLAGS="-L${PREFIX}/usr/lib/"

stack setup
stack update
ldconfig
stack install --local-bin-path ${PREFIX}/bin
#Renaming to bin.
mv ${PREFIX}/bin/feht ${PREFIX}/bin/feht-bin
#Let everyone read and execute the file.
chmod 755 ${PREFIX}/bin/feht-bin
#cleanup
rm -r .stack-work