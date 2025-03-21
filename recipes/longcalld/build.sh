#!/bin/bash

mkdir -p $PREFIX/bin

make -f Makefile.conda

chmod 0755 bin/longcallD
cp -f bin/longcallD $PREFIX/bin/
