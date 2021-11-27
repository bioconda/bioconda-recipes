#! /bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export MACOSX_DEPLOYMENT_TARGET=10.13

cargo build --release

# try to find where binary is. it seems that the binary
# uses some other variable here: target/<other-var>/vartrix
VARTRIX_BIN=$(find . -type f -name "vartrix")
cp -a $VARTRIX_BIN ${PREFIX}/bin/vartrix
