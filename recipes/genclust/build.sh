#!/bin/bash

make
mkdir -p $PREFIX/bin
cp genclust $PREFIX/bin
