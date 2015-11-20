#!/bin/bash

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
    sed -i 's/LDFLAGS=-Wl,-s/LDFLAGS=/g' smithwaterman/Makefile
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
sed -i 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/g' tabixpp/Makefile
sed -i 's/-ltabix//g' Makefile

make

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
