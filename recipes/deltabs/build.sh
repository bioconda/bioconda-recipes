#!/bin/bash

mkdir -p $PREFIX/bin

chmod +x src/*.pl
cp src/deltaBS.pl $PREFIX/bin
cp src/buildCustomModels.pl $PREFIX/bin

