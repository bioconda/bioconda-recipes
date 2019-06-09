#!/bin/bash

## SET APPROPRIATE ENVIRONMENT VARIABLES AND BUILD
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"

## MAKE EXECUTABLES EXECUTABLE!
chmod a+x ./build/ataqv
chmod a+x ./src/scripts/mkarv
chmod a+x ./src/scripts/srvarv

## COPY BINARIES TO ENVIRONMENT INSTALLATION BIN DIRECTORY
mkdir -p $PREFIX/bin
cp ./build/ataqv $PREFIX/bin/
cp ./src/scripts/mkarv $PREFIX/bin/
cp ./src/scripts/srvarv $PREFIX/bin/

## COPY WEB DIRECTORY REQUIRED BY MKARV
mkdir -p $PREFIX/web
cp -r ./src/web/* $PREFIX/web/
