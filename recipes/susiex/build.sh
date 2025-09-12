#!/bin/bash

mkdir -p $PREFIX/bin

pushd src
make
popd
cp bin/SuSiEx $PREFIX/bin/SuSiEx
