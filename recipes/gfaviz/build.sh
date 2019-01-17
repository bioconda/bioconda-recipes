#!/bin/bash

mkdir -p $PREFIX/bin

qmake
make
cp viz.x $PREFIX/bin

