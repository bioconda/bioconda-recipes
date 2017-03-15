#!/bin/bash

mkdir -p $PREFIX/bin
mkdir bin && cd src/cpp
make
cp ../../bin/* $PREFIX/bin
