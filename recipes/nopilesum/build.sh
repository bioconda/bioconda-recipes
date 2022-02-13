#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

cp $PREFIX/lib/libhts* .

dub build -b release -c bioconda
./nopilesum
cp nopilesum $PREFIX/bin
