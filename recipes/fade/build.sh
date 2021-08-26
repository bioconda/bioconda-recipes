#!/bin/bash

# download and install parasail
echo "Downloading and installing parasail"
if [ "$(uname)" != "Darwin" ]; then
    wget https://github.com/jeffdaily/parasail/releases/download/v2.4.3/parasail-2.4.3-manylinux1_x86_64.tar.gz
else
    wget https://github.com/jeffdaily/parasail/releases/download/v2.4.3/parasail-2.4.3-Darwin-10.13.6.tar.gz
fi
tar -xzf parasail-2.4.3*.tar.gz
cp -r parasail-2.4.3*/lib/* $PREFIX/lib

# downloading D compiler
echo "Downloading ldc2 1.26.0 D compiler"
curl -fsS https://dlang.org/install.sh -o install.sh
chmod +x install.sh
DENV=$(./install.sh ldc-1.26.0 -p $PWD -a)

# activating D compiler env
. $DENV
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

# build fade binary
cd $SRC_DIR
echo "building fade binary"

cp $PREFIX/lib/libhts* .
cp $PREFIX/lib/libparasail* .

dub build -b release -c bioconda
cp ldc-1.26.0/lib/* $PREFIX/lib
deactivate

export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

# run binary as test and move binary to bin
./fade
cp fade $PREFIX/bin
