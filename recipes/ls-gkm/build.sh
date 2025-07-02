#!/bin/bash

cd src
make
make install

mkdir -p $PREFIX/bin
mv ../bin/gkmtrain $PREFIX/bin
mv ../bin/gkmpredict $PREFIX/bin
