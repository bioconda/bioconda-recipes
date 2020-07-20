#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDES="-I$PREFIX/include"
cp hifiasm $PREFIX/bin
