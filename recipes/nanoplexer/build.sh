#!/bin/bash

mkdir -p $PREFIX/bin
make
cp ./bin/nanoplexer $PREFIX/bin/nanoplexer

