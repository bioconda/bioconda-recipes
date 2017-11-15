#!/bin/bash

mkdir -p "${PREFIX}/bin"

cd src
MAKEFILE=Makefile.Linux
if [ `uname` = "Darwin" ];
then
  MAKEFILE=Makefile.MacOS
fi
make -f $MAKEFILE
cd ..
cp bin/utilities/* $PREFIX/bin
rm -r bin/utilities
cp bin/* $PREFIX/bin
