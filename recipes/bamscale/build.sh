#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

export PATH=$BUILD_PREFIX/bin:$PATH

pushd bamscale
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" nbproject/Makefile-Release.mk
make
cp bin/BAMscale "$PREFIX/bin"
popd
