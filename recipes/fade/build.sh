#!/bin/bash

# downloading D compiler
echo "Downloading ldc2 1.26.0 D compiler"
curl -fsS https://dlang.org/install.sh -o install.sh
chmod +x install.sh
DENV=$(./install.sh ldc-1.26.0 -p $PWD -a)

# activating D compiler env
. $DENV

# build fade binary
cd $SRC_DIR
echo "building fade binary"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
dub build -b release
cp ldc-1.26.0/lib/* $PREFIX/lib
deactivate

# run binary as test and move binary to bin
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
./fade
cp fade $PREFIX/bin
