#!/bin/bash

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' smithwaterman/Makefile
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' tabixpp/Makefile
sed -i.bak 's/-ltabix//' Makefile

# https://github.com/bioconda/bioconda-recipes/pull/1201
sed -i.bak 's/^CPPFLAGS =$//g' tabixpp/htslib/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' tabixpp/htslib/Makefile

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
