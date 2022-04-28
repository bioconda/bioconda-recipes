#! /bin/bash
cargo build --release

# try to find where binary is. it seems that the binary
# uses some other variable here: target/<other-var>/vartrix
VARTRIX_BIN=$(find . -type f -name "vartrix")
cp -a $VARTRIX_BIN ${PREFIX}/bin/vartrix
