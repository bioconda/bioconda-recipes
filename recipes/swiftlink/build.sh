#!/bin/sh

cd src
make -f Makefile.nocuda
cd -

cp -v src/swift $PREFIX/bin/swiftlink
