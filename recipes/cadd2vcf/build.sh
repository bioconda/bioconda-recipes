#!/bin/bash

# downloading D compiler
echo "Downloading ldc2 1.26.0 D compiler"
curl -fsS https://dlang.org/install.sh -o install.sh
chmod +x install.sh
DENV=$(./install.sh ldc-1.26.0 -p $PWD -a)

# activating D compiler env
. $DENV
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

# build cadd2vcf binary
cd $SRC_DIR
echo "building cadd2vcf binary"

cp $PREFIX/lib/libhts* .

dub build -b release -c bioconda
cp ldc-1.26.0/lib/* $PREFIX/lib
deactivate

export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

# run binary as test and move binary to bin
./cadd2vcf
cp cadd2vcf $PREFIX/bin