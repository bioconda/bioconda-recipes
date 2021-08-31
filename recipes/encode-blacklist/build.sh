#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
mkdir -p $PREFIX/bin/
sed -i.bak "s#g++#${CXX}#" Makefile
if [ "$(uname)" == Darwin ] ; then
  sed -i.bak "s#std::fmod#fmod#" blacklist.cpp
fi
make
cp Blacklist $PREFIX/bin/
