#!/bin/bash

make -j

mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin
