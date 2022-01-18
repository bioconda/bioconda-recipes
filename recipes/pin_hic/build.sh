#!/bin/bash
mkdir bin
pushd src
make CC=$CC
popd
pushd util
make CC=$CC
popd
mv bin/* $PREFIX/bin/
