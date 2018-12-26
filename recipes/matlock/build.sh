#!/bin/bash

mkdir -p $PREFIX/bin
make
cp src/matlock $PREFIX/bin
