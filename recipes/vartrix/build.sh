#!/bin/bash -euo

cargo build --release

# try to find where binary is. it seems that the binary
# uses some other variable here: target/<other-var>/vartrix
VARTRIX_BIN=$(find . -type f -name "vartrix")
chmod 755 $VARTRIX_BIN
cp -af $VARTRIX_BIN ${PREFIX}/bin/vartrix
