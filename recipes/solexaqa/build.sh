#!/bin/sh

set -e -u -x

cd source

# fix up the makefile as follows:
# - use $(CXX) instead of $(CC), to pick up the conda C++ compiler
# - don't use the gcc C++11 ABI, which is incompatible with how boost is built
# - add in missing libraries
sed -i.bak -e 's/\$(CC)/$(CXX)/' -e '/CFLAGS=/s/$/ -D_GLIBCXX_USE_CXX11_ABI=0/' -e '/LIBS=/s/-lpthread/-licutu -licui18n -licuuc -licudata -ldl -lpthread/' makefile

BOOST_PATH=$PREFIX make

BIN=$PREFIX/bin
mkdir -p $BIN
cp -a $SRC_DIR/source/SolexaQA++ $BIN
