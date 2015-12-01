#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

rsync -a bin/ $PREFIX/bin
rsync -a lib/ $PREFIX/lib
rsync -a include/ $PREFIX/include

