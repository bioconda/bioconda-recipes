#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' smithwaterman/Makefile
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' tabixpp/Makefile
sed -i.bak 's/-ltabix//' Makefile

make

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
